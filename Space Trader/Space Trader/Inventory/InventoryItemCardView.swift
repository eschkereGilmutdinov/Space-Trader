import SwiftUI

struct InventoryItemCardView: View {
	let item: InventoryItem
	
	var body: some View {
		VStack(alignment: .leading, spacing: 10) {
			HStack(alignment: .top) {
				VStack(alignment: .leading, spacing: 6) {
					Text(item.name)
						.font(.custom("Montserrat-Bold", size: 20))
						.foregroundStyle(.white)
					
					Text(item.description)
						.font(.custom("Montserrat-Regular", size: 14))
						.foregroundStyle(.white.opacity(0.75))
				}
				
				Spacer()
				
				VStack(alignment: .trailing, spacing: 4) {
					Text("x\(item.quantity)")
						.font(.custom("Montserrat-Regular", size: 15))
						.foregroundStyle(.green)
					
					Text("\(item.price)$")
						.font(.custom("Montserrat-Regular", size: 15))
						.foregroundStyle(.white.opacity(0.8))
				}
			}
			
			Text("Общая стоимость: \(item.price * item.quantity)$")
				.font(.custom("Montserrat-Regular", size: 14))
				.foregroundStyle(.green)
		}
		.padding()
		.frame(maxWidth: .infinity, alignment: .leading)
		.background(Color.white.opacity(0.12))
		.clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
	}
}
