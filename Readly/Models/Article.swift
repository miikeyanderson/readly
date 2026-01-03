import Foundation
import SwiftData

/// Article source entity representing an article from which highlights are taken.
@Model
final class Article {
    /// Unique identifier
    var id: UUID

    /// Article title
    var title: String

    /// Source publication or website
    var source: String

    /// URL to the original article
    var url: String?

    /// All highlights from this article
    @Relationship(deleteRule: .cascade, inverse: \Highlight.article)
    var highlights: [Highlight]

    /// When this article was added
    var addedAt: Date

    init(
        id: UUID = UUID(),
        title: String,
        source: String,
        url: String? = nil,
        highlights: [Highlight] = [],
        addedAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.source = source
        self.url = url
        self.highlights = highlights
        self.addedAt = addedAt
    }
}

extension Article {
    /// Number of highlights from this article
    var highlightCount: Int {
        highlights.count
    }
}
