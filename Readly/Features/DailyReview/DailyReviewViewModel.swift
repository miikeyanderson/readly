import SwiftUI

@MainActor
@Observable
final class DailyReviewViewModel {
    var highlights: [Highlight] = []
    var currentIndex = 0
    var isLoading = false
    var errorMessage: String?
    var isSessionComplete = false
    var favoritedCount = 0
    var discardedCount = 0
    var keptCount = 0

    private var session: ReviewSession?
    private let reviewService: ReviewService
    private let highlightService: HighlightService
    private let onComplete: () -> Void
    private let onDismiss: () -> Void

    init(
        reviewService: ReviewService,
        highlightService: HighlightService,
        onComplete: @escaping () -> Void,
        onDismiss: @escaping () -> Void
    ) {
        self.reviewService = reviewService
        self.highlightService = highlightService
        self.onComplete = onComplete
        self.onDismiss = onDismiss
    }

    var currentHighlight: Highlight? {
        currentIndex < highlights.count ? highlights[currentIndex] : nil
    }

    var progress: Double {
        highlights.isEmpty ? 0 : Double(currentIndex) / Double(highlights.count)
    }

    var progressText: String {
        highlights.isEmpty ? "" : "\(currentIndex + 1) of \(highlights.count)"
    }

    var hasMoreHighlights: Bool {
        currentIndex < highlights.count
    }

    func loadHighlights() async {
        isLoading = true
        errorMessage = nil

        do {
            highlights = try reviewService.getTodaysHighlights()
            session = try reviewService.getTodaysSession()
            if highlights.isEmpty {
                isSessionComplete = true
            }
        } catch {
            errorMessage = "Failed to load highlights"
        }

        isLoading = false
    }

    func favoriteCurrentHighlight() {
        guard let highlight = currentHighlight else { return }
        reviewService.markReviewed(highlight, quality: .favorite)
        favoritedCount += 1
        advanceToNext()
    }

    func discardCurrentHighlight() {
        guard let highlight = currentHighlight else { return }
        reviewService.markReviewed(highlight, quality: .discard)
        discardedCount += 1
        advanceToNext()
    }

    func keepCurrentHighlight() {
        guard let highlight = currentHighlight else { return }
        reviewService.markReviewed(highlight, quality: .keep)
        keptCount += 1
        advanceToNext()
    }

    func editCurrentHighlight() {
        // TODO: Implement edit functionality
    }

    func dismiss() {
        onDismiss()
    }

    func completeSession() {
        if let session {
            reviewService.completeSession(session)
            try? reviewService.save()
        }
        onComplete()
    }

    private func advanceToNext() {
        if let session {
            reviewService.updateSession(session, reviewed: 1, favorited: 0, discarded: 0)
        }
        try? reviewService.save()

        currentIndex += 1

        if !hasMoreHighlights {
            isSessionComplete = true
            if let session {
                reviewService.completeSession(session)
                try? reviewService.save()
            }
        }
    }
}
