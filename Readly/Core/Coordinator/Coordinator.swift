import SwiftUI

/// Base protocol for all coordinators in the MVVM-C architecture.
/// Coordinators manage navigation flow and own child coordinators.
@MainActor
protocol Coordinator: AnyObject {
    associatedtype ContentView: View

    /// Child coordinators managed by this coordinator
    var childCoordinators: [any Coordinator] { get set }

    /// Creates and returns the root view for this coordinator
    @ViewBuilder func start() -> ContentView
}

extension Coordinator {
    /// Adds a child coordinator to be managed
    func addChild(_ coordinator: any Coordinator) {
        childCoordinators.append(coordinator)
    }

    /// Removes a child coordinator when its flow is complete
    func removeChild(_ coordinator: any Coordinator) {
        childCoordinators.removeAll { $0 === coordinator }
    }

    /// Removes all child coordinators
    func removeAllChildren() {
        childCoordinators.removeAll()
    }
}
