import SwiftUI

/// Coordinator managing the Daily Review flow presentation.
@MainActor
@Observable
final class DailyReviewCoordinator: Coordinator {
    var childCoordinators: [any Coordinator] = []

    private let serviceContainer: ServiceContainer
    private let onDismiss: () -> Void

    init(
        serviceContainer: ServiceContainer,
        onDismiss: @escaping () -> Void
    ) {
        self.serviceContainer = serviceContainer
        self.onDismiss = onDismiss
    }

    func start() -> some View {
        DailyReviewView(viewModel: makeDailyReviewViewModel())
            .environment(\.serviceContainer, serviceContainer)
    }

    // MARK: - Actions

    func dismiss() {
        onDismiss()
    }

    // MARK: - View Model Factory

    private func makeDailyReviewViewModel() -> DailyReviewViewModel {
        DailyReviewViewModel(
            reviewService: serviceContainer.reviewService,
            highlightService: serviceContainer.highlightService,
            onComplete: { [weak self] in
                self?.dismiss()
            },
            onDismiss: { [weak self] in
                self?.dismiss()
            }
        )
    }
}
