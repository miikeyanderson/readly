import SwiftUI

/// Root coordinator managing the main tab-based navigation.
@MainActor
@Observable
final class AppCoordinator: Coordinator {
    var childCoordinators: [any Coordinator] = []

    private let serviceContainer: ServiceContainer

    /// Currently selected tab
    var selectedTab: Tab = .home

    /// Available tabs in the app
    enum Tab: Int, CaseIterable {
        case home
        case highlights
        case books
        case articles
        case profile

        var title: String {
            switch self {
            case .home: "Review"
            case .highlights: "Highlights"
            case .books: "Books"
            case .articles: "Articles"
            case .profile: "Profile"
            }
        }

        var icon: String {
            switch self {
            case .home: "book.pages"
            case .highlights: "highlighter"
            case .books: "books.vertical"
            case .articles: "doc.text"
            case .profile: "person"
            }
        }
    }

    init(serviceContainer: ServiceContainer) {
        self.serviceContainer = serviceContainer
    }

    func start() -> some View {
        TabView(selection: Binding(
            get: { self.selectedTab },
            set: { self.selectedTab = $0 }
        )) {
            ForEach(Tab.allCases, id: \.self) { tab in
                self.tabContent(for: tab)
                    .tabItem {
                        Label(tab.title, systemImage: tab.icon)
                    }
                    .tag(tab)
            }
        }
    }

    @ViewBuilder
    private func tabContent(for tab: Tab) -> some View {
        switch tab {
        case .home:
            homeCoordinator.start()
        case .highlights:
            HighlightsFeedView()
        case .books:
            BooksView()
        case .articles:
            ArticlesView()
        case .profile:
            ProfileView()
        }
    }

    // MARK: - Child Coordinators

    private var _homeCoordinator: HomeCoordinator?
    private var homeCoordinator: HomeCoordinator {
        if let existing = _homeCoordinator { return existing }
        let coordinator = HomeCoordinator(serviceContainer: serviceContainer)
        addChild(coordinator)
        _homeCoordinator = coordinator
        return coordinator
    }
}
