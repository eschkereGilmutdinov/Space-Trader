import SwiftUI

struct TradeSectionView: View {
	let title: String
	let subtitle: String
	let items: [TradeItem]
	let accentColor: Color
	let actionTitle: String
	let quantityProvider: (TradeItem) -> Int?
	let priceProvider: (TradeItem) -> Int
	let isActionDisabled: (TradeItem) -> Bool
	let action: (TradeItem) -> Void
	
	init (
		title: String,
		subtitle: String,
		items: [TradeItem],
		accentColor: Color,
		actionTitle: String,
		quantityProvider: @escaping (TradeItem) -> Int? = {_ in nil},
		priceProvider: @escaping (TradeItem) -> Int = { $0.price },
		isActionDisabled: @escaping (TradeItem) -> Bool = {_ in false },
		action: @escaping (TradeItem) -> Void = {_ in }
	) {
		self.title = title
		self.subtitle = subtitle
		self.items = items
		self.accentColor = accentColor
		self.actionTitle = actionTitle
		self.quantityProvider = quantityProvider
		self.priceProvider = priceProvider
		self.isActionDisabled = isActionDisabled
		self.action = action
	}
	
	var body: some View {
		VStack(alignment: .leading, spacing: 12) {
			Text(title)
				.font(.custom("Montserrat-Regular", size: 22))
				.bold()
				.foregroundStyle(.white)
			
			Text(subtitle)
				.font(.custom("Montserrat-Regular", size: 14))
				.foregroundStyle(Color.white.opacity(0.7))
			
			if items.isEmpty {
				Text("Список пока пуст")
					.foregroundStyle(Color.white.opacity(0.7))
					.padding()
					.frame(maxWidth: .infinity, alignment: .leading)
					.background(Color.white.opacity(0.08))
					.clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
			} else {
				ForEach(items) { item in
					VStack(alignment: .leading, spacing: 6) {
						HStack {
							Text(item.name)
								.font(.custom("Montserrat-Regular", size: 18))
								.foregroundStyle(.white)
							Spacer()
							Text("\(priceProvider(item))$")
								.font(.custom("Montserrat-Regular", size: 18))
								.foregroundStyle(accentColor)
								.bold()
						}
						
						Text(item.description)
							.font(.custom("Montserrat-Regular", size: 14))
							.foregroundStyle(Color.white.opacity(0.75))
						
						HStack {
							if let quantity = quantityProvider(item) {
								Text("В инвенторе: \(quantity)")
									.font(.custom("Montserrat-Regular", size: 13))
									.foregroundStyle(.white.opacity(0.75))
							}
							
							Spacer()
							
							Button(actionTitle) {
								action(item)
							}
							.font(.custom("Montserrat-Bold", size: 14))
							.padding(.horizontal, 14)
							.padding(.vertical, 8)
							.background(
								isActionDisabled(item)
								? Color.white.opacity(0.12)
								: accentColor.opacity(0.9)
							)
							.foregroundStyle(.white)
							.clipShape(Capsule())
							.disabled(isActionDisabled(item))
						}
					}
					.padding()
					.frame(maxWidth: .infinity, alignment: .leading)
					.background(Color.white.opacity(0.12))
					.clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
				}
			}
		}
	}
}
