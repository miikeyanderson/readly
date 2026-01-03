import SwiftUI

/// Stub view for the Profile tab.
/// Contains user settings and account information.
struct ProfileView: View {
    var body: some View {
        NavigationStack {
            VStack {
                ContentUnavailableView(
                    "Profile",
                    systemImage: "person.circle",
                    description: Text("Your profile and settings will appear here")
                )
            }
            .navigationTitle("Profile")
        }
    }
}

#Preview {
    ProfileView()
}
