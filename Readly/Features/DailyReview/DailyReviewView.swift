import SwiftUI

/// Main view for the Daily Review experience with card stack and actions.
struct DailyReviewView: View {
    @Bindable var viewModel: DailyReviewViewModel

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()

                if viewModel.isLoading {
                    ProgressView("Loading highlights...")
                } else if viewModel.isSessionComplete {
                    completionView
                } else if let highlight = viewModel.currentHighlight {
                    reviewContent(highlight: highlight)
                } else {
                    emptyStateView
                }
            }
            .navigationTitle("Daily Review")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") {
                        viewModel.dismiss()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    if !viewModel.highlights.isEmpty && !viewModel.isSessionComplete {
                        Text(viewModel.progressText)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .task {
                await viewModel.loadHighlights()
            }
        }
    }

    // MARK: - Review Content

    private func reviewContent(highlight: Highlight) -> some View {
        VStack(spacing: 0) {
            // Progress bar
            ProgressView(value: viewModel.progress)
                .tint(.blue)
                .padding(.horizontal)
                .padding(.top, 8)

            // Card
            ScrollView {
                ReviewCardView(highlight: highlight)
                    .padding()
            }

            // Actions
            ReviewActionsView(
                onDiscard: viewModel.discardCurrentHighlight,
                onMaster: viewModel.editCurrentHighlight,
                onFeedback: viewModel.editCurrentHighlight,
                onKeep: viewModel.keepCurrentHighlight,
                onFavorite: viewModel.favoriteCurrentHighlight
            )
            .padding(.bottom)
        }
    }

    // MARK: - Completion View

    private var completionView: some View {
        VStack(spacing: 24) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundStyle(.green)

            Text("Review Complete!")
                .font(.title)
                .fontWeight(.bold)

            VStack(spacing: 12) {
                summaryRow(icon: "heart.fill", color: .red, text: "\(viewModel.favoritedCount) favorited")
                summaryRow(icon: "checkmark", color: .green, text: "\(viewModel.keptCount) kept")
                summaryRow(icon: "xmark", color: .gray, text: "\(viewModel.discardedCount) discarded")
            }
            .padding()
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 12))

            Button(action: viewModel.completeSession) {
                Text("Done")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.blue)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal, 40)
        }
        .padding()
    }

    private func summaryRow(icon: String, color: Color, text: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(color)
            Text(text)
            Spacer()
        }
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "tray")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)

            Text("No Highlights to Review")
                .font(.title2)
                .fontWeight(.semibold)

            Text("All caught up! Check back tomorrow.")
                .foregroundStyle(.secondary)

            Button("Close") {
                viewModel.dismiss()
            }
            .buttonStyle(.bordered)
        }
        .padding()
    }
}

#Preview {
    DailyReviewView(
        viewModel: DailyReviewViewModel(
            reviewService: PreviewHelper.reviewService,
            highlightService: PreviewHelper.highlightService,
            onComplete: {},
            onDismiss: {}
        )
    )
}
