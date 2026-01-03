import SwiftUI

/// Stub view for the Books tab.
/// Displays the user's book library.
struct BooksView: View {
    var body: some View {
        NavigationStack {
            VStack {
                ContentUnavailableView(
                    "Books",
                    systemImage: "books.vertical",
                    description: Text("Your book library will appear here")
                )
            }
            .navigationTitle("Books")
        }
    }
}

#Preview {
    BooksView()
}
