import Foundation
import SwiftData

@Model
final class ReviewSession {
    var id: UUID
    var date: Date
    var highlightsReviewed: Int
    var highlightsFavorited: Int
    var highlightsDiscarded: Int
    var completedAt: Date?
    var durationSeconds: Int

    init(
        id: UUID = UUID(),
        date: Date = Calendar.current.startOfDay(for: Date()),
        highlightsReviewed: Int = 0,
        highlightsFavorited: Int = 0,
        highlightsDiscarded: Int = 0,
        completedAt: Date? = nil,
        durationSeconds: Int = 0
    ) {
        self.id = id
        self.date = date
        self.highlightsReviewed = highlightsReviewed
        self.highlightsFavorited = highlightsFavorited
        self.highlightsDiscarded = highlightsDiscarded
        self.completedAt = completedAt
        self.durationSeconds = durationSeconds
    }

    var isComplete: Bool { completedAt != nil }

    var formattedDuration: String {
        let minutes = durationSeconds / 60
        let seconds = durationSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}
