import SwiftUI

/// Action bar for the Daily Review with Like, Discard, Edit, and Keep buttons.
struct ReviewActionsView: View {
    let onDiscard: () -> Void
    let onMaster: () -> Void
    let onFeedback: () -> Void
    let onKeep: () -> Void
    let onFavorite: () -> Void

    var body: some View {
        HStack(spacing: 0) {
            // Discard button
            actionButton(
                icon: "xmark",
                label: "Discard",
                action: onDiscard
            )

            Spacer()

            // Master button
            actionButton(
                icon: "sparkles",
                label: "Master",
                action: onMaster
            )

            Spacer()

            // Feedback button
            actionButton(
                icon: "clock",
                label: "Feedback",
                action: onFeedback
            )

            Spacer()

            // Keep button (with highlight)
            Button(action: onKeep) {
                VStack(spacing: 6) {
                    ZStack {
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 56, height: 56)

                        Image(systemName: "checkmark")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                    }

                    Text("Keep")
                        .font(.caption)
                        .foregroundStyle(.primary)
                }
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 24)
    }

    private func actionButton(
        icon: String,
        label: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(spacing: 6) {
                ZStack {
                    Circle()
                        .stroke(Color(.systemGray4), lineWidth: 1.5)
                        .frame(width: 48, height: 48)

                    Image(systemName: icon)
                        .font(.title3)
                        .foregroundStyle(.primary)
                }

                Text(label)
                    .font(.caption)
                    .foregroundStyle(.primary)
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    VStack {
        Spacer()
        ReviewActionsView(
            onDiscard: {},
            onMaster: {},
            onFeedback: {},
            onKeep: {},
            onFavorite: {}
        )
        .padding()
    }
    .background(Color(.systemGroupedBackground))
}
