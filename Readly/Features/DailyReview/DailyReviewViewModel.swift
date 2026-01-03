import SwiftUI

/// ViewModel for the Daily Review session managing card stack and actions.
@MainActor
@Observable
final class DailyReviewViewModel {
    // MARK: - Published State

    /// All highlights for this review session
    var highlights: [Highlight] = []

    /// Current index in the highlight stack
    var currentIndex: Int = 0

    /// Loading state
    var isLoading: Bool = false

    /// Error message if any
    var errorMessage: String?

    /// Whether the review session is complete
    var isSessionComplete: Bool = false

    /// Current review session
    private var session: ReviewSession?

    /// Counts for summary
    var favoritedCount: Int = 0
    var discardedCount: Int = 0
    var keptCount: Int = 0

    // MARK: - Dependencies

    private let reviewService: ReviewService
    private let highlightService: HighlightService
    private let onComplete: () -> Void
    private let onDismiss: () -> Void

    // MARK: - Initialization

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

    // MARK: - Computed Properties

    /// Current highlight being reviewed
    var currentHighlight: Highlight? {
        guard currentIndex < highlights.count else { return nil }
        return highlights[currentIndex]
    }

    /// Progress through the review (0.0 - 1.0)
    var progress: Double {
        guard !highlights.isEmpty else { return 0 }
        return Double(currentIndex) / Double(highlights.count)
    }

    /// Progress text (e.g., "1 of 5")
    var progressText: String {
        guard !highlights.isEmpty else { return "" }
        return "\(currentIndex + 1) of \(highlights.count)"
    }

    /// Whether there are more highlights to review
    var hasMoreHighlights: Bool {
        currentIndex < highlights.count
    }

    // MARK: - Actions

    /// Loads today's highlights for review
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

    /// Marks the current highlight as favorite and moves to next
    func favoriteCurrentHighlight() {
        guard let highlight = currentHighlight else { return }

        reviewService.markReviewed(highlight, quality: .favorite)
        favoritedCount += 1
        updateSessionAndAdvance()
    }

    /// Discards the current highlight and moves to next
    func discardCurrentHighlight() {
        guard let highlight = currentHighlight else { return }

        reviewService.markReviewed(highlight, quality: .discard)
        discardedCount += 1
        updateSessionAndAdvance()
    }

    /// Keeps the current highlight and moves to next
    func keepCurrentHighlight() {
        guard let highlight = currentHighlight else { return }

        reviewService.markReviewed(highlight, quality: .keep)
        keptCount += 1
        updateSessionAndAdvance()
    }

    /// Opens feedback/edit for the current highlight
    func editCurrentHighlight() {
        // TODO: Implement edit functionality
    }

    /// Dismisses the review session
    func dismiss() {
        onDismiss()
    }

    /// Completes and closes the review session
    func completeSession() {
        if let session {
            reviewService.completeSession(session)
            try? reviewService.save()
        }
        onComplete()
    }

    // MARK: - Private Methods

    private func updateSessionAndAdvance() {
        // Update session stats
        if let session {
            reviewService.updateSession(
                session,
                reviewed: 1,
                favorited: 0,
                discarded: 0
            )
        }

        // Save changes
        try? reviewService.save()

        // Move to next highlight
        currentIndex += 1

        // Check if session is complete
        if !hasMoreHighlights {
            isSessionComplete = true
            if let session {
                reviewService.completeSession(session)
                try? reviewService.save()
            }
        }
    }
}
