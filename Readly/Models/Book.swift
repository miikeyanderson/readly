import Foundation
import SwiftData

@Model
final class Book {
    var id: UUID
    var title: String
    var author: String
    var coverURL: String?

    @Relationship(deleteRule: .cascade, inverse: \Highlight.book)
    var highlights: [Highlight]

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

    var highlightCount: Int { highlights.count }
}
