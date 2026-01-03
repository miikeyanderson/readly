import SwiftUI

/// Coordinator for the Home tab, managing navigation to Daily Review and other features.
@MainActor
@Observable
final class HomeCoordinator: Coordinator {
    var childCoordinators: [any Coordinator] = []

    private let serviceContainer: ServiceContainer

    /// Navigation state for presenting Daily Review
    var showingDailyReview = false

    init(serviceContainer: ServiceContainer) {
        self.serviceContainer = serviceContainer
    }

    func start() -> some View {
        HomeView(viewModel: makeHomeViewModel())
            .environment(\.serviceContainer, serviceContainer)
            .fullScreenCover(isPresented: Binding(
                get: { self.showingDailyReview },
                set: { self.showingDailyReview = $0 }
            )) {
                dailyReviewCoordinator.start()
            }
    }

    // MARK: - Actions

    func showDailyReview() {
        showingDailyReview = true
    }

    func dismissDailyReview() {
        showingDailyReview = false
        removeChild(dailyReviewCoordinator)
    }

    // MARK: - View Model Factory

    private func makeHomeViewModel() -> HomeViewModel {
        HomeViewModel(
            reviewService: serviceContainer.reviewService,
            onStartReview: { [weak self] in
                self?.showDailyReview()
            }
        )
    }

    // MARK: - Child Coordinators

    private lazy var dailyReviewCoordinator: DailyReviewCoordinator = {
        let coordinator = DailyReviewCoordinator(
            serviceContainer: serviceContainer,
            onDismiss: { [weak self] in
                self?.dismissDailyReview()
            }
        )
        addChild(coordinator)
        return coordinator
    }()
}
