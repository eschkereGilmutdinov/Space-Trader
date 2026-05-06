import SwiftUI

struct UpgradeView : View {
	@EnvironmentObject var session: SessionStore
	@State private var upgradeMessage: String?
	@State private var buyingUpgradeId: String?
	
	private var cards: [UpgradeCard] {
		let upgrades = session.upgrades
		
		return [
			UpgradeCard(
				id: "speed",
				title: "Скорость корабля",
				subtitle: "+10% к скорости перелёта за уровень",
				icon: "speedometer",
				tint: .cyan,
				level: upgrades.speedLevel,
				maxLevel: upgrades.maxLevel,
				cost: upgrades.speedCost
			),
			UpgradeCard(
				id: "profit",
				title: "Увеличение прибыли",
				subtitle: "+8% к цене продажи товаров за уровень",
				icon: "dollarsign.circle.fill",
				tint: .green,
				level: upgrades.profitLevel,
				maxLevel: upgrades.maxLevel,
				cost: upgrades.profitCost
			),
			UpgradeCard(
				id: "fuel_efficiency",
				title: "Экономия топлива",
				subtitle: "-7% к расходу топлива за уровень",
				icon: "fuelpump.fill",
				tint: .orange,
				level: upgrades.fuelEfficiencyLevel,
				maxLevel: upgrades.maxLevel,
				cost: upgrades.fuelEfficiencyCost
			),
			UpgradeCard(
				id: "durability",
				title: "Прочность корабля",
				subtitle: "+12% к прочности корпуса за уровень",
				icon: "shield.lefthalf.filled",
				tint: .purple,
				level: upgrades.durabilityLevel,
				maxLevel: upgrades.maxLevel,
				cost: upgrades.durabilityCost
			)
		]
	}
    var body: some View {
		ZStack {
			Color.black.ignoresSafeArea()
			
			ScrollView {
				VStack(alignment: .leading, spacing: 16) {
					VStack(alignment: .leading, spacing: 8) {
						Text("Улучшения")
							.font(.custom("Montserrat-Bold", size: 28))
							.foregroundStyle(.white)
						Text("Баланс: \(Int(session.balance ?? 0))$")
							.font(.custom("Montserrat-Regular", size: 18))
							.foregroundStyle(.green.opacity(0.9))
					}
					
					UpgradeInfoView()
					
					if let upgradeMessage {
						UpgradeMessageView(message: upgradeMessage)
					}
					
					ForEach(cards) { card in
						UpgradeCardView(
							card: card,
							balance: session.balance ?? 0,
							isBuying: buyingUpgradeId == card.id
						) {
							buy(card)
						}
					}
				}
				.padding(20)
			}
		}
		.task {
			await session.refreshUpgrades()
		}
    }
	
	private func buy(_ card: UpgradeCard) {
		guard buyingUpgradeId == nil else { return }
		
		buyingUpgradeId = card.id
		upgradeMessage = nil
		
		Task { @MainActor in
			do {
				try await session.buyUpgrades(type: card.id)
				upgradeMessage = "Улучшено \(card.title)"
			} catch {
				upgradeMessage = error.localizedDescription
			}
			
			buyingUpgradeId = nil
		}
	}
}
