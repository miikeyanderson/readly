import Foundation
import SwiftData

/// Service for CRUD operations on highlights.
@MainActor
final class HighlightService {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: - Fetch Operations

    /// Fetches all highlights, optionally filtered and sorted
    func fetchAll(
        sortBy: SortDescriptor<Highlight> = SortDescriptor(\.createdAt, order: .reverse)
    ) throws -> [Highlight] {
        let descriptor = FetchDescriptor<Highlight>(sortBy: [sortBy])
        return try modelContext.fetch(descriptor)
    }

    /// Fetches highlights for a specific book
    func fetchHighlights(for book: Book) throws -> [Highlight] {
        let bookID = book.id
        let predicate = #Predicate<Highlight> { highlight in
            highlight.book?.id == bookID
        }
        let descriptor = FetchDescriptor<Highlight>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        return try modelContext.fetch(descriptor)
    }

    /// Fetches highlights for a specific article
    func fetchHighlights(for article: Article) throws -> [Highlight] {
        let articleID = article.id
        let predicate = #Predicate<Highlight> { highlight in
            highlight.article?.id == articleID
        }
        let descriptor = FetchDescriptor<Highlight>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        return try modelContext.fetch(descriptor)
    }

    /// Fetches favorite highlights
    func fetchFavorites() throws -> [Highlight] {
        let predicate = #Predicate<Highlight> { $0.isFavorite }
        let descriptor = FetchDescriptor<Highlight>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        return try modelContext.fetch(descriptor)
    }

    /// Fetches highlights by tag
    func fetchHighlights(withTag tag: String) throws -> [Highlight] {
        let allHighlights = try fetchAll()
        return allHighlights.filter { $0.tags.contains(tag) }
    }

    // MARK: - Create Operations

    /// Creates a new highlight
    @discardableResult
    func create(
        text: String,
        note: String? = nil,
        book: Book? = nil,
        article: Article? = nil,
        tags: [String] = []
    ) -> Highlight {
        let highlight = Highlight(
            text: text,
            note: note,
            book: book,
            article: article,
            tags: tags
        )
        modelContext.insert(highlight)
        return highlight
    }

    // MARK: - Update Operations

    /// Updates a highlight's note
    func updateNote(_ highlight: Highlight, note: String?) {
        highlight.note = note
    }

    /// Toggles the favorite status of a highlight
    func toggleFavorite(_ highlight: Highlight) {
        highlight.isFavorite.toggle()
    }

    /// Adds a tag to a highlight
    func addTag(_ tag: String, to highlight: Highlight) {
        if !highlight.tags.contains(tag) {
            highlight.tags.append(tag)
        }
    }

    /// Removes a tag from a highlight
    func removeTag(_ tag: String, from highlight: Highlight) {
        highlight.tags.removeAll { $0 == tag }
    }

    // MARK: - Delete Operations

    /// Deletes a highlight
    func delete(_ highlight: Highlight) {
        modelContext.delete(highlight)
    }

    /// Deletes multiple highlights
    func delete(_ highlights: [Highlight]) {
        for highlight in highlights {
            modelContext.delete(highlight)
        }
    }

    // MARK: - Save

    /// Saves any pending changes
    func save() throws {
        try modelContext.save()
    }
}
