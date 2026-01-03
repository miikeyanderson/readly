import SwiftUI

/// Card displaying a single highlight for review.
struct ReviewCardView: View {
    let highlight: Highlight

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Source header
            sourceHeader

            // Highlight text
            highlightText

            // User note (if present)
            if let note = highlight.note, !note.isEmpty {
                userNote(note)
            }

            // Tags
            if !highlight.tags.isEmpty {
                tagsView
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
    }

    // MARK: - Source Header

    private var sourceHeader: some View {
        HStack(spacing: 12) {
            // Book/Article cover placeholder
            RoundedRectangle(cornerRadius: 4)
                .fill(Color(.systemGray5))
                .frame(width: 40, height: 56)
                .overlay {
                    Image(systemName: highlight.book != nil ? "book.closed" : "doc.text")
                        .foregroundStyle(.secondary)
                }

            VStack(alignment: .leading, spacing: 4) {
                Text(highlight.sourceTitle)
                    .font(.headline)
                    .lineLimit(2)

                if let author = highlight.sourceAuthor {
                    Text(author)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            // Expand button
            Button(action: {}) {
                Image(systemName: "chevron.down")
                    .foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - Highlight Text

    private var highlightText: some View {
        Text(highlight.text)
            .font(.body)
            .lineSpacing(6)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - User Note

    private func userNote(_ note: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Your Note")
                .font(.caption)
                .foregroundStyle(.secondary)
                .textCase(.uppercase)

            Text(note)
                .font(.callout)
                .foregroundStyle(.secondary)
                .italic()
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    // MARK: - Tags

    private var tagsView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(highlight.tags, id: \.self) { tag in
                    TagChip(tag: tag, onRemove: nil)
                }
            }
        }
    }
}

/// Small chip displaying a tag with optional remove action.
struct TagChip: View {
    let tag: String
    let onRemove: (() -> Void)?

    var body: some View {
        HStack(spacing: 4) {
            Text(tag)
                .font(.caption)
                .fontWeight(.medium)

            if let onRemove {
                Button(action: onRemove) {
                    Image(systemName: "xmark")
                        .font(.caption2)
                }
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color.blue.opacity(0.15))
        .foregroundStyle(.blue)
        .clipShape(Capsule())
    }
}

#Preview {
    ScrollView {
        ReviewCardView(highlight: PreviewHelper.sampleHighlight)
            .padding()
    }
    .background(Color(.systemGroupedBackground))
}
