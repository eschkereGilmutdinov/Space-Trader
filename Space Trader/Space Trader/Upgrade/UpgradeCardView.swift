import SwiftUI

struct UpgradeCardView: View {
	let card: UpgradeCard
	let balance: Double
	let isBuying: Bool
	let onBuy: () -> Void
	
	private var isMaxed: Bool {
		card.level >= card.maxLevel
	}
	private var canAfford: Bool {
		balance >= (card.cost ?? Double.greatestFiniteMagnitude)
	}
	
	var body: some View {
		VStack(alignment: .leading, spacing: 12) {
			HStack(alignment: .top, spacing: 12) {
				Image(systemName: card.icon)
					.font(.system(size: 24, weight: .bold))
					.foregroundStyle(card.tint)
					.frame(width: 44, height: 44)
					.background(card.tint.opacity(0.18))
					.clipShape(Circle())
				VStack(alignment: .leading, spacing: 6) {
					Text(card.title)
						.font(.custom("Montserrat-Bold", size: 19))
						.foregroundStyle(.white)
					Text(card.subtitle)
						.font(.custom("Montserrat-Regular", size: 14))
						.foregroundStyle(.white.opacity(0.72))
				}
			}
			Spacer()
			
			ProgressView(value: Double(card.level), total: Double(card.maxLevel))
			
			HStack {
				Text("Уровень \(card.level)/\(card.maxLevel)")
					.font(.custom("Montserrat-Regular", size: 14))
					.foregroundStyle(.white)
				
				Spacer()
				
				Button {
					onBuy()
				} label: {
					Text(buttonTitle)
						.font(.custom("Montserrat-Bold", size: 14))
						.foregroundStyle(.white)
						.padding(.horizontal, 14)
						.padding(.vertical, 9)
						.background(buttonBackground)
						.clipShape(Capsule())
				}
				.disabled(isMaxed || !canAfford || isBuying)
			}
		}
	}
		
	private var buttonTitle: String {
		if (isMaxed) {
			return "Максимум"
		}
		
		return "Улучшить за \(Int(card.cost ?? 0))$"
	}
	
	private var buttonBackground: Color {
		if isMaxed || !canAfford || isBuying {
			return Color.white.opacity(0.14)
		}
		
		return card.tint.opacity(0.9)
	}
}
