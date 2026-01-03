import Foundation
import SwiftData

/// Tracks a daily review session for analytics and streak tracking.
@Model
final class ReviewSession {
    /// Unique identifier
    var id: UUID

    /// The date of the review session (normalized to start of day)
    var date: Date

    /// Number of highlights reviewed in this session
    var highlightsReviewed: Int

    /// Number of highlights marked as favorite during this session
    var highlightsFavorited: Int

    /// Number of highlights discarded during this session
    var highlightsDiscarded: Int

    /// When the session was completed (nil if incomplete)
    var completedAt: Date?

    /// Duration of the session in seconds
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
}

extension ReviewSession {
    /// Whether this session has been completed
    var isComplete: Bool {
        completedAt != nil
    }

    /// Formatted duration string
    var formattedDuration: String {
        let minutes = durationSeconds / 60
        let seconds = durationSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}
