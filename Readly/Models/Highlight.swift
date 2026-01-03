import Foundation
import SwiftData

/// Core highlight entity representing a passage from a book or article.
/// Includes spaced repetition metadata for the review system.
@Model
final class Highlight {
    /// Unique identifier
    var id: UUID

    /// The highlighted text content
    var text: String

    /// User's personal note or annotation
    var note: String?

    /// Reference to the source book (if from a book)
    var book: Book?

    /// Reference to the source article (if from an article)
    var article: Article?

    /// When the highlight was created
    var createdAt: Date

    /// When the highlight was last reviewed
    var lastReviewedAt: Date?

    /// When the highlight should next be reviewed (spaced repetition)
    var nextReviewAt: Date?

    /// Total number of times this highlight has been reviewed
    var reviewCount: Int

    /// Whether the user has marked this as a favorite
    var isFavorite: Bool

    /// Ease factor for SM-2 algorithm (default 2.5)
    var easeFactor: Double

    /// Current interval in days for spaced repetition
    var intervalDays: Int

    /// Tags associated with this highlight
    var tags: [String]

    init(
        id: UUID = UUID(),
        text: String,
        note: String? = nil,
        book: Book? = nil,
        article: Article? = nil,
        createdAt: Date = Date(),
        lastReviewedAt: Date? = nil,
        nextReviewAt: Date? = nil,
        reviewCount: Int = 0,
        isFavorite: Bool = false,
        easeFactor: Double = 2.5,
        intervalDays: Int = 0,
        tags: [String] = []
    ) {
        self.id = id
        self.text = text
        self.note = note
        self.book = book
        self.article = article
        self.createdAt = createdAt
        self.lastReviewedAt = lastReviewedAt
        self.nextReviewAt = nextReviewAt
        self.reviewCount = reviewCount
        self.isFavorite = isFavorite
        self.easeFactor = easeFactor
        self.intervalDays = intervalDays
        self.tags = tags
    }
}

extension Highlight {
    /// The source title (book or article)
    var sourceTitle: String {
        book?.title ?? article?.title ?? "Unknown Source"
    }

    /// The source author
    var sourceAuthor: String? {
        book?.author ?? article?.source
    }

    /// Whether this highlight is due for review
    var isDueForReview: Bool {
        guard let nextReviewAt else { return true }
        return nextReviewAt <= Date()
    }
}
