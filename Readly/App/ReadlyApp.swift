import SwiftUI
import SwiftData

@main
struct ReadlyApp: App {
    let modelContainer: ModelContainer
    let serviceContainer: ServiceContainer

    init() {
        // Configure SwiftData ModelContainer
        let schema = Schema([
            Highlight.self,
            Book.self,
            Article.self,
            ReviewSession.self
        ])

        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )

        do {
            modelContainer = try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }

        // Initialize ServiceContainer with the main context
        let context = modelContainer.mainContext
        serviceContainer = ServiceContainer(modelContext: context)

        // Seed sample data if needed (for development)
        #if DEBUG
        Task { @MainActor in
            SeedData.seedIfNeeded(context: context)
        }
        #endif
    }

    var body: some Scene {
        WindowGroup {
            AppCoordinator(serviceContainer: serviceContainer)
                .start()
        }
        .modelContainer(modelContainer)
        .environment(\.serviceContainer, serviceContainer)
    }
}
