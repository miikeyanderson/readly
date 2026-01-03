import SwiftUI

@MainActor
protocol Coordinator: AnyObject {
    associatedtype ContentView: View
    var childCoordinators: [any Coordinator] { get set }
    @ViewBuilder func start() -> ContentView
}

extension Coordinator {
    func addChild(_ coordinator: any Coordinator) {
        childCoordinators.append(coordinator)
    }

    func removeChild(_ coordinator: any Coordinator) {
        childCoordinators.removeAll { $0 === coordinator }
    }

    func removeAllChildren() {
        childCoordinators.removeAll()
    }
}
