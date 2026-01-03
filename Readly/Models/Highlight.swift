import Foundation
import SwiftData

@Model
final class Highlight {
    var id: UUID
    var text: String
    var note: String?
    var book: Book?
    var article: Article?
    var createdAt: Date
    var lastReviewedAt: Date?
    var nextReviewAt: Date?
    var reviewCount: Int
    var isFavorite: Bool
    var easeFactor: Double
    var intervalDays: Int
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

    var sourceTitle: String {
        book?.title ?? article?.title ?? "Unknown Source"
    }

    var sourceAuthor: String? {
        book?.author ?? article?.source
    }

    var isDueForReview: Bool {
        guard let nextReviewAt else { return true }
        return nextReviewAt <= Date()
    }
}
