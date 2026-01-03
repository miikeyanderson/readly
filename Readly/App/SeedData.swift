import Foundation
import SwiftData

/// Development seed data for testing the app
@MainActor
enum SeedData {
    /// Seeds the database with sample data if empty
    static func seedIfNeeded(context: ModelContext) {
        // Check if we already have data
        let highlightDescriptor = FetchDescriptor<Highlight>()
        guard (try? context.fetchCount(highlightDescriptor)) == 0 else {
            return
        }

        // Create sample books
        let book1 = Book(
            title: "Stillness Is the Key",
            author: "Ryan Holiday"
        )

        let book2 = Book(
            title: "The Extended Mind",
            author: "Annie Murphy Paul"
        )

        let book3 = Book(
            title: "Make It Stick",
            author: "Peter C. Brown"
        )

        let book4 = Book(
            title: "Thinking, Fast and Slow",
            author: "Daniel Kahneman"
        )

        context.insert(book1)
        context.insert(book2)
        context.insert(book3)
        context.insert(book4)

        // Create sample highlights
        let highlights = [
            Highlight(
                text: "Stillness is what aims the archer's arrow. It inspires new ideas. It sharpens perspective and illuminates connections. It slows the ball down so that we might hit it.",
                note: "Great reminder about the power of stillness",
                book: book1,
                tags: ["productivity", "mindfulness"]
            ),
            Highlight(
                text: "Leadership isn't about being in charge. Leadership is about taking care of those in your charge.",
                note: nil,
                book: book1,
                tags: ["leadership"]
            ),
            Highlight(
                text: "\"Nonconscious information acquisition,\" as Lewicki calls it, along with the ensuing application of such information, is happening in our lives all the time.",
                note: "Our senses can be rewired",
                book: book2,
                tags: ["learning", "cognition"]
            ),
            Highlight(
                text: "Spatial intelligence: three-dimensional judgment and the ability to visualize with the mind's eye.",
                note: nil,
                book: book3,
                tags: ["intelligence"]
            ),
            Highlight(
                text: "The confidence we experience as we make a judgment is not a reasoned evaluation of the probability that it is right. Confidence is a feeling, which reflects the coherence of the information and the cognitive ease of processing it.",
                note: "Confidence != accuracy",
                book: book4,
                tags: ["psychology", "decision-making"]
            )
        ]

        for highlight in highlights {
            context.insert(highlight)
        }

        // Create a sample article
        let article = Article(
            title: "The Science of Spaced Repetition",
            source: "Nature",
            url: "https://nature.com/articles/spaced-repetition"
        )
        context.insert(article)

        let articleHighlight = Highlight(
            text: "Spaced repetition exploits the psychological spacing effect, where information is more easily recalled if exposure to it is repeated over a longer span of time.",
            note: "Core principle behind this app",
            article: article,
            tags: ["learning", "memory"]
        )
        context.insert(articleHighlight)

        try? context.save()
    }
}
