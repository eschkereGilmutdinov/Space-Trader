import SwiftUI

struct ProfileView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Profile")
                .font(.headline)
        }
        .padding()
    }
}
