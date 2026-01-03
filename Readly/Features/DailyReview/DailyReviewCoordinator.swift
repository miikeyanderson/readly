import SwiftUI

@MainActor
@Observable
final class DailyReviewCoordinator: Coordinator {
    var childCoordinators: [any Coordinator] = []

    private let serviceContainer: ServiceContainer
    private let onDismiss: () -> Void

    init(serviceContainer: ServiceContainer, onDismiss: @escaping () -> Void) {
        self.serviceContainer = serviceContainer
        self.onDismiss = onDismiss
    }

    func start() -> some View {
        DailyReviewView(viewModel: makeViewModel())
            .environment(\.serviceContainer, serviceContainer)
    }

    func dismiss() {
        onDismiss()
    }

    private func makeViewModel() -> DailyReviewViewModel {
        DailyReviewViewModel(
            reviewService: serviceContainer.reviewService,
            highlightService: serviceContainer.highlightService,
            onComplete: { [weak self] in self?.dismiss() },
            onDismiss: { [weak self] in self?.dismiss() }
        )
    }
}
