import Foundation
import SwiftData

/// Book source entity representing a book from which highlights are taken.
@Model
final class Book {
    /// Unique identifier
    var id: UUID

    /// Book title
    var title: String

    /// Book author
    var author: String

    /// URL to the book cover image
    var coverURL: String?

    /// All highlights from this book
    @Relationship(deleteRule: .cascade, inverse: \Highlight.book)
    var highlights: [Highlight]

    /// When this book was added to the library
    var addedAt: Date

    init(
        id: UUID = UUID(),
        title: String,
        author: String,
        coverURL: String? = nil,
        highlights: [Highlight] = [],
        addedAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.author = author
        self.coverURL = coverURL
        self.highlights = highlights
        self.addedAt = addedAt
    }
}

extension Book {
    /// Number of highlights from this book
    var highlightCount: Int {
        highlights.count
    }
}
