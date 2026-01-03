import SwiftUI

@MainActor
@Observable
final class HomeCoordinator: Coordinator {
    var childCoordinators: [any Coordinator] = []
    var showingDailyReview = false

    private let serviceContainer: ServiceContainer

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
                self.dailyReviewCoordinator.start()
            }
    }

    func showDailyReview() {
        showingDailyReview = true
    }

    func dismissDailyReview() {
        showingDailyReview = false
        removeChild(dailyReviewCoordinator)
    }

    private func makeHomeViewModel() -> HomeViewModel {
        HomeViewModel(
            reviewService: serviceContainer.reviewService,
            onStartReview: { [weak self] in self?.showDailyReview() }
        )
    }

    private var _dailyReviewCoordinator: DailyReviewCoordinator?
    private var dailyReviewCoordinator: DailyReviewCoordinator {
        if let existing = _dailyReviewCoordinator { return existing }
        let coordinator = DailyReviewCoordinator(
            serviceContainer: serviceContainer,
            onDismiss: { [weak self] in self?.dismissDailyReview() }
        )
        addChild(coordinator)
        _dailyReviewCoordinator = coordinator
        return coordinator
    }
}
