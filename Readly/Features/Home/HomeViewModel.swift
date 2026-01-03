import SwiftUI

/// ViewModel for the Home screen managing review status and dashboard data.
@MainActor
@Observable
final class HomeViewModel {
    // MARK: - Published State

    /// Number of highlights due for review today
    var todayReviewCount: Int = 0

    /// Whether today's review has been completed
    var isReviewComplete: Bool = false

    /// Current review streak (consecutive days)
    var streak: Int = 0

    /// Loading state
    var isLoading: Bool = false

    /// Error message if any
    var errorMessage: String?

    /// Current date for display
    var currentDate: Date = Date()

    // MARK: - Dependencies

    private let reviewService: ReviewService
    private let onStartReview: () -> Void

    // MARK: - Initialization

    init(
        reviewService: ReviewService,
        onStartReview: @escaping () -> Void
    ) {
        self.reviewService = reviewService
        self.onStartReview = onStartReview
    }

    // MARK: - Actions

    /// Loads the dashboard data
    func loadData() async {
        isLoading = true
        errorMessage = nil

        do {
            todayReviewCount = try reviewService.getTodaysReviewCount()
            isReviewComplete = try reviewService.isTodaysReviewComplete()
            streak = try reviewService.getCurrentStreak()
            currentDate = Date()
        } catch {
            errorMessage = "Failed to load review data"
        }

        isLoading = false
    }

    /// Starts the daily review flow
    func startDailyReview() {
        onStartReview()
    }

    // MARK: - Computed Properties

    /// Formatted date string for display
    var formattedDate: String {
        currentDate.formatted(date: .long, time: .omitted)
    }

    /// Review status message
    var reviewStatusMessage: String {
        if isReviewComplete {
            return "You've completed today's review."
        } else if todayReviewCount == 0 {
            return "No highlights due for review."
        } else {
            return "\(todayReviewCount) highlight\(todayReviewCount == 1 ? "" : "s") to review"
        }
    }
}
