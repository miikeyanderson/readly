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
                dailyReviewCoordinator.start()
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

    private lazy var dailyReviewCoordinator: DailyReviewCoordinator = {
        let coordinator = DailyReviewCoordinator(
            serviceContainer: serviceContainer,
            onDismiss: { [weak self] in self?.dismissDailyReview() }
        )
        addChild(coordinator)
        return coordinator
    }()
}
