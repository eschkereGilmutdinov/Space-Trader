import SwiftUI

struct TradeView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "cart")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Торговля")
                .font(.headline)
        }
        .padding()
    }
}
