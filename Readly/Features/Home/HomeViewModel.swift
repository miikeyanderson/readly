import SwiftUI

@MainActor
@Observable
final class HomeViewModel {
    var todayReviewCount = 0
    var isReviewComplete = false
    var streak = 0
    var isLoading = false
    var errorMessage: String?
    var currentDate = Date()

    private let reviewService: ReviewService
    private let onStartReview: () -> Void

    init(reviewService: ReviewService, onStartReview: @escaping () -> Void) {
        self.reviewService = reviewService
        self.onStartReview = onStartReview
    }

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

    func startDailyReview() {
        onStartReview()
    }

    var formattedDate: String {
        currentDate.formatted(date: .long, time: .omitted)
    }

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
