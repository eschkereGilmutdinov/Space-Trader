import SwiftUI

struct InventoryHeaderView: View {
	let totalItemsCount: Int
	let balance: Double?
	
	var body: some View {
		VStack(alignment: .leading, spacing: 8) {
			Text("Инвентарь")
				.font(.custom("Montserrat-Regular", size: 32))
				.foregroundStyle(.white)
			Text("Товаров всего: \(totalItemsCount)")
				.font(.custom("Montserrat-Regular", size: 18))
				.foregroundStyle(.white)
			Text("Баланс: \(Int(balance ?? 0))$")
				.font(.custom("Montserrat-Regular", size: 18))
				.foregroundStyle(.green)
		}
	}
}
