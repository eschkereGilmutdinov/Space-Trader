import SwiftUI

struct StationView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Главная")
                .font(.headline)
        }
        .padding()
    }
}
