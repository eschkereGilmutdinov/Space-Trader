import SwiftUI

struct InventoryEmptyStateView: View {
	var body: some View {
		VStack(alignment: .leading, spacing: 10) {
			Text("Инвентарь пуст")
				.font(.custom("Montserrat-Regular", size: 22))
				.foregroundStyle(.white)
			Text("Товары можно купить на станции")
				.font(.custom("Montserrat-Regular", size: 16))
				.foregroundStyle(.white.opacity(0.85))
		}
		.padding()
		.frame(maxWidth: .infinity, alignment: .leading)
		.background(Color.white.opacity(0.12))
		.clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
	}
}
