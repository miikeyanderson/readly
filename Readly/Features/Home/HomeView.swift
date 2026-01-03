import SwiftUI

/// Home dashboard view with Daily Review entry point and feature cards.
struct HomeView: View {
    @Bindable var viewModel: HomeViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Daily Review Card
                    dailyReviewCard

                    // Feature Cards
                    featureCardsSection
                }
                .padding()
            }
            .navigationTitle("Readwise")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {}) {
                        Image(systemName: "bell")
                            .foregroundStyle(.primary)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 4) {
                        Image(systemName: "bolt.fill")
                            .foregroundStyle(.orange)
                        Text("\(viewModel.streak)")
                            .fontWeight(.semibold)
                    }
                }
            }
            .task {
                await viewModel.loadData()
            }
        }
    }

    // MARK: - Daily Review Card

    private var dailyReviewCard: some View {
        Button(action: viewModel.startDailyReview) {
            VStack(alignment: .leading, spacing: 12) {
                Text(viewModel.formattedDate)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.8))

                Divider()
                    .background(.white.opacity(0.3))

                Text("Daily Review")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)

                Spacer()

                HStack(spacing: 8) {
                    if viewModel.isReviewComplete {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.white)
                    }
                    Text(viewModel.reviewStatusMessage)
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.9))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(24)
            .frame(height: 200)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [Color.blue, Color.blue.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Feature Cards

    private var featureCardsSection: some View {
        VStack(spacing: 16) {
            featureCard(
                title: "Highlights Feed",
                icon: "rectangle.stack",
                color: .blue
            )

            featureCard(
                title: "Mastery Feed",
                icon: "chart.line.uptrend.xyaxis",
                color: .orange
            )
        }
    }

    private func featureCard(title: String, icon: String, color: Color) -> some View {
        HStack {
            Text(title)
                .font(.title2)
                .fontWeight(.semibold)

            Spacer()

            Image(systemName: icon)
                .font(.title)
                .foregroundStyle(color)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray6))
        )
    }
}

#Preview {
    HomeView(
        viewModel: HomeViewModel(
            reviewService: PreviewHelper.reviewService,
            onStartReview: {}
        )
    )
}
