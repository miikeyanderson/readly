import SwiftUI

/// Stub view for the Articles tab.
/// Displays saved articles.
struct ArticlesView: View {
    var body: some View {
        NavigationStack {
            VStack {
                ContentUnavailableView(
                    "Articles",
                    systemImage: "doc.text",
                    description: Text("Your saved articles will appear here")
                )
            }
            .navigationTitle("Articles")
        }
    }
}

#Preview {
    ArticlesView()
}
