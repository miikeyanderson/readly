import SwiftUI
import SwiftData

/// Helper for creating preview instances with mock data
@MainActor
enum PreviewHelper {
    static let modelContainer: ModelContainer = {
        let schema = Schema([
            Highlight.self,
            Book.self,
            Article.self,
            ReviewSession.self
        ])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: schema, configurations: [config])

        // Add sample data
        let book = Book(title: "Sample Book", author: "Author Name")
        container.mainContext.insert(book)

        let highlight = Highlight(
            text: "This is a sample highlight text for preview purposes.",
            note: "A sample note",
            book: book
        )
        container.mainContext.insert(highlight)

        return container
    }()

    static var modelContext: ModelContext {
        modelContainer.mainContext
    }

    static var highlightService: HighlightService {
        HighlightService(modelContext: modelContext)
    }

    static var reviewService: ReviewService {
        ReviewService(modelContext: modelContext)
    }

    static var serviceContainer: ServiceContainer {
        ServiceContainer(modelContext: modelContext)
    }

    static var sampleHighlight: Highlight {
        let book = Book(title: "Stillness Is the Key", author: "Ryan Holiday")
        return Highlight(
            text: "Stillness is what aims the archer's arrow. It inspires new ideas.",
            note: "Great insight",
            book: book,
            tags: ["mindfulness"]
        )
    }
}
