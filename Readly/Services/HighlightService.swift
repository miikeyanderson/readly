import Foundation
import SwiftData

@MainActor
final class HighlightService {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: - Fetch

    func fetchAll(sortBy: SortDescriptor<Highlight> = SortDescriptor(\.createdAt, order: .reverse)) throws -> [Highlight] {
        try modelContext.fetch(FetchDescriptor<Highlight>(sortBy: [sortBy]))
    }

    func fetchHighlights(for book: Book) throws -> [Highlight] {
        let bookID = book.id
        let predicate = #Predicate<Highlight> { $0.book?.id == bookID }
        return try modelContext.fetch(FetchDescriptor<Highlight>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        ))
    }

    func fetchHighlights(for article: Article) throws -> [Highlight] {
        let articleID = article.id
        let predicate = #Predicate<Highlight> { $0.article?.id == articleID }
        return try modelContext.fetch(FetchDescriptor<Highlight>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        ))
    }

    func fetchFavorites() throws -> [Highlight] {
        let predicate = #Predicate<Highlight> { $0.isFavorite }
        return try modelContext.fetch(FetchDescriptor<Highlight>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        ))
    }

    func fetchHighlights(withTag tag: String) throws -> [Highlight] {
        try fetchAll().filter { $0.tags.contains(tag) }
    }

    // MARK: - Create

    @discardableResult
    func create(
        text: String,
        note: String? = nil,
        book: Book? = nil,
        article: Article? = nil,
        tags: [String] = []
    ) -> Highlight {
        let highlight = Highlight(text: text, note: note, book: book, article: article, tags: tags)
        modelContext.insert(highlight)
        return highlight
    }

    // MARK: - Update

    func updateNote(_ highlight: Highlight, note: String?) {
        highlight.note = note
    }

    func toggleFavorite(_ highlight: Highlight) {
        highlight.isFavorite.toggle()
    }

    func addTag(_ tag: String, to highlight: Highlight) {
        guard !highlight.tags.contains(tag) else { return }
        highlight.tags.append(tag)
    }

    func removeTag(_ tag: String, from highlight: Highlight) {
        highlight.tags.removeAll { $0 == tag }
    }

    // MARK: - Delete

    func delete(_ highlight: Highlight) {
        modelContext.delete(highlight)
    }

    func delete(_ highlights: [Highlight]) {
        highlights.forEach { modelContext.delete($0) }
    }

    func save() throws {
        try modelContext.save()
    }
}
