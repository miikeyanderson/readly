import SwiftUI
import SwiftData

@MainActor
@Observable
final class ServiceContainer {
    let highlightService: HighlightService
    let reviewService: ReviewService

    init(modelContext: ModelContext) {
        self.highlightService = HighlightService(modelContext: modelContext)
        self.reviewService = ReviewService(modelContext: modelContext)
    }
}

// MARK: - Environment

private struct ServiceContainerKey: EnvironmentKey {
    static let defaultValue: ServiceContainer? = nil
}

extension EnvironmentValues {
    var serviceContainer: ServiceContainer? {
        get { self[ServiceContainerKey.self] }
        set { self[ServiceContainerKey.self] = newValue }
    }
}
