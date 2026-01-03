import Foundation
import SwiftData

@MainActor
final class ReviewService {
    private let modelContext: ModelContext
    private let dailyReviewCount = 5

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: - Daily Review

    func getTodaysHighlights() throws -> [Highlight] {
        let now = Date()
        let predicate = #Predicate<Highlight> { highlight in
            highlight.nextReviewAt == nil || highlight.nextReviewAt! <= now
        }
        let descriptor = FetchDescriptor<Highlight>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.nextReviewAt, order: .forward)]
        )
        let highlights = try modelContext.fetch(descriptor)
        return Array(highlights.prefix(dailyReviewCount))
    }

    func getTodaysReviewCount() throws -> Int {
        let now = Date()
        let predicate = #Predicate<Highlight> { highlight in
            highlight.nextReviewAt == nil || highlight.nextReviewAt! <= now
        }
        return try modelContext.fetchCount(FetchDescriptor<Highlight>(predicate: predicate))
    }

    // MARK: - Review Actions

    enum ReviewQuality: Int {
        case discard = 0
        case keep = 3
        case favorite = 5
    }

    func markReviewed(_ highlight: Highlight, quality: ReviewQuality) {
        highlight.lastReviewedAt = Date()
        highlight.reviewCount += 1
        if quality == .favorite {
            highlight.isFavorite = true
        }
        calculateNextReview(highlight, quality: quality.rawValue)
    }

    private func calculateNextReview(_ highlight: Highlight, quality: Int) {
        let newEaseFactor = highlight.easeFactor + (0.1 - Double(5 - quality) * (0.08 + Double(5 - quality) * 0.02))
        highlight.easeFactor = max(1.3, newEaseFactor)

        let newInterval: Int
        switch highlight.reviewCount {
        case 1: newInterval = 1
        case 2: newInterval = 6
        default: newInterval = Int(Double(highlight.intervalDays) * highlight.easeFactor)
        }

        let adjustedInterval: Int
        switch quality {
        case 0...2: adjustedInterval = max(1, newInterval / 2)
        case 5: adjustedInterval = Int(Double(newInterval) * 1.3)
        default: adjustedInterval = newInterval
        }

        highlight.intervalDays = adjustedInterval
        highlight.nextReviewAt = Calendar.current.date(byAdding: .day, value: adjustedInterval, to: Date())
    }

    // MARK: - Session Management

    func getTodaysSession() throws -> ReviewSession {
        let today = Calendar.current.startOfDay(for: Date())
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!

        let predicate = #Predicate<ReviewSession> { session in
            session.date >= today && session.date < tomorrow
        }
        let sessions = try modelContext.fetch(FetchDescriptor<ReviewSession>(predicate: predicate))

        if let existing = sessions.first {
            return existing
        }

        let session = ReviewSession(date: today)
        modelContext.insert(session)
        return session
    }

    func updateSession(_ session: ReviewSession, reviewed: Int, favorited: Int, discarded: Int) {
        session.highlightsReviewed += reviewed
        session.highlightsFavorited += favorited
        session.highlightsDiscarded += discarded
    }

    func completeSession(_ session: ReviewSession) {
        session.completedAt = Date()
    }

    func isTodaysReviewComplete() throws -> Bool {
        try getTodaysSession().isComplete
    }

    // MARK: - Streak

    func getCurrentStreak() throws -> Int {
        let sessions = try modelContext.fetch(
            FetchDescriptor<ReviewSession>(sortBy: [SortDescriptor(\.date, order: .reverse)])
        )
        guard !sessions.isEmpty else { return 0 }

        var streak = 0
        var expectedDate = Calendar.current.startOfDay(for: Date())

        for session in sessions {
            let sessionDay = Calendar.current.startOfDay(for: session.date)
            if session.isComplete && sessionDay == expectedDate {
                streak += 1
                expectedDate = Calendar.current.date(byAdding: .day, value: -1, to: expectedDate)!
            } else if sessionDay < expectedDate {
                break
            }
        }
        return streak
    }

    func save() throws {
        try modelContext.save()
    }
}
