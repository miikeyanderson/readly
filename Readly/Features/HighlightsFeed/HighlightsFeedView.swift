import SwiftUI

/// Stub view for the Highlights Feed tab.
/// Displays a scrollable list of all highlights.
struct HighlightsFeedView: View {
    var body: some View {
        NavigationStack {
            VStack {
                ContentUnavailableView(
                    "Highlights Feed",
                    systemImage: "highlighter",
                    description: Text("Your highlights will appear here")
                )
            }
            .navigationTitle("Highlights")
        }
    }
}

#Preview {
    HighlightsFeedView()
}
