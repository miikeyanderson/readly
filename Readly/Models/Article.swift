import Foundation
import SwiftData

@Model
final class Article {
    var id: UUID
    var title: String
    var source: String
    var url: String?

    @Relationship(deleteRule: .cascade, inverse: \Highlight.article)
    var highlights: [Highlight]

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

    var highlightCount: Int { highlights.count }
}
