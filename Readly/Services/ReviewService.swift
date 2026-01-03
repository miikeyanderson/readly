import Foundation
import SwiftData

/// Service for spaced repetition scheduling and review session management.
/// Uses a simplified SM-2 algorithm for calculating review intervals.
@MainActor
final class ReviewService {
    private let modelContext: ModelContext

    /// Number of highlights to include in daily review
    private let dailyReviewCount = 5

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: - Daily Review

    /// Gets highlights due for today's review
    func getTodaysHighlights() throws -> [Highlight] {
        let now = Date()
        let predicate = #Predicate<Highlight> { highlight in
            highlight.nextReviewAt == nil || highlight.nextReviewAt! <= now
        }
        let descriptor = FetchDescriptor<Highlight>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.nextReviewAt, order: .forward)]
        )
        var highlights = try modelContext.fetch(descriptor)

        // Limit to daily review count
        if highlights.count > dailyReviewCount {
            highlights = Array(highlights.prefix(dailyReviewCount))
        }

        return highlights
    }

    /// Gets the count of highlights due for review today
    func getTodaysReviewCount() throws -> Int {
        let now = Date()
        let predicate = #Predicate<Highlight> { highlight in
            highlight.nextReviewAt == nil || highlight.nextReviewAt! <= now
        }
        let descriptor = FetchDescriptor<Highlight>(predicate: predicate)
        return try modelContext.fetchCount(descriptor)
    }

    // MARK: - Review Actions

    /// Quality ratings for SM-2 algorithm
    enum ReviewQuality: Int {
        case discard = 0    // User wants to discard - don't show again soon
        case keep = 3       // User keeps - normal progression
        case favorite = 5   // User favorites - slower progression (already memorable)
    }

    /// Marks a highlight as reviewed with the given quality rating
    func markReviewed(_ highlight: Highlight, quality: ReviewQuality) {
        highlight.lastReviewedAt = Date()
        highlight.reviewCount += 1

        switch quality {
        case .favorite:
            highlight.isFavorite = true
            // Favorites get longer intervals since user already remembers them
            calculateNextReview(highlight, quality: quality.rawValue)
        case .discard:
            // Discarded items come back sooner for reinforcement
            calculateNextReview(highlight, quality: quality.rawValue)
        case .keep:
            // Normal progression
            calculateNextReview(highlight, quality: quality.rawValue)
        }
    }

    /// SM-2 Algorithm implementation for calculating next review date
    private func calculateNextReview(_ highlight: Highlight, quality: Int) {
        // Update ease factor
        let newEaseFactor = highlight.easeFactor + (0.1 - Double(5 - quality) * (0.08 + Double(5 - quality) * 0.02))
        highlight.easeFactor = max(1.3, newEaseFactor)

        // Calculate new interval
        let newInterval: Int
        if highlight.reviewCount == 1 {
            newInterval = 1
        } else if highlight.reviewCount == 2 {
            newInterval = 6
        } else {
            newInterval = Int(Double(highlight.intervalDays) * highlight.easeFactor)
        }

        // Adjust interval based on quality
        let adjustedInterval: Int
        switch quality {
        case 0...2:  // Poor quality - shorter interval
            adjustedInterval = max(1, newInterval / 2)
        case 5:      // Excellent - can extend interval
            adjustedInterval = Int(Double(newInterval) * 1.3)
        default:
            adjustedInterval = newInterval
        }

        highlight.intervalDays = adjustedInterval
        highlight.nextReviewAt = Calendar.current.date(
            byAdding: .day,
            value: adjustedInterval,
            to: Date()
        )
    }

    // MARK: - Review Session Management

    /// Gets or creates today's review session
    func getTodaysSession() throws -> ReviewSession {
        let today = Calendar.current.startOfDay(for: Date())
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!

        let predicate = #Predicate<ReviewSession> { session in
            session.date >= today && session.date < tomorrow
        }
        let descriptor = FetchDescriptor<ReviewSession>(predicate: predicate)
        let sessions = try modelContext.fetch(descriptor)

        if let existingSession = sessions.first {
            return existingSession
        }

        // Create new session for today
        let newSession = ReviewSession(date: today)
        modelContext.insert(newSession)
        return newSession
    }

    /// Updates the current session with review results
    func updateSession(_ session: ReviewSession, reviewed: Int, favorited: Int, discarded: Int) {
        session.highlightsReviewed += reviewed
        session.highlightsFavorited += favorited
        session.highlightsDiscarded += discarded
    }

    /// Marks a session as complete
    func completeSession(_ session: ReviewSession) {
        session.completedAt = Date()
    }

    /// Checks if today's review is complete
    func isTodaysReviewComplete() throws -> Bool {
        let session = try getTodaysSession()
        return session.isComplete
    }

    // MARK: - Streak Tracking

    /// Calculates the current review streak (consecutive days)
    func getCurrentStreak() throws -> Int {
        let descriptor = FetchDescriptor<ReviewSession>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        let sessions = try modelContext.fetch(descriptor)

        guard !sessions.isEmpty else { return 0 }

        var streak = 0
        var expectedDate = Calendar.current.startOfDay(for: Date())

        for session in sessions {
            let sessionDay = Calendar.current.startOfDay(for: session.date)

            if session.isComplete && sessionDay == expectedDate {
                streak += 1
                expectedDate = Calendar.current.date(byAdding: .day, value: -1, to: expectedDate)!
            } else if sessionDay < expectedDate {
                // Gap in streak
                break
            }
        }

        return streak
    }

    // MARK: - Save

    /// Saves any pending changes
    func save() throws {
        try modelContext.save()
    }
}
