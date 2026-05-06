import SwiftUI

struct TradeView: View {
	@EnvironmentObject private var session: SessionStore
	
	@State private var tradeMessage: String?
	@State private var isTradeInProgress = false
	private let backgroundImageName = "Background"
	
	private var currentStation: Station? {
		session.currentStation
	}
	
	private var goodsForSaleAtCurrentStation: [TradeItem] {
		currentStation?.tradeItems ?? []
	}
	
	private var goodsYouCanSellHere: [TradeItem] {
		guard let currentStation else {
			return []
		}
		return stations
			.filter { $0.id != currentStation.id }
			.flatMap(\.tradeItems)
	}
	private var formattedBalance: String {
		"\(Int(session.balance ?? 0))$"
	}
	var body: some View {
		NavigationStack {
			ZStack {
				Color.black.ignoresSafeArea()
				
				Image(backgroundImageName)
					.resizable()
					.scaledToFill()
					.ignoresSafeArea()
				
				ScrollView {
					VStack(alignment: .leading, spacing: 12) {
						HStack(alignment: .top) {
							VStack(alignment: .leading, spacing: 8) {
								Text("Торговля")
									.font(.custom("Montserrat-Bold", size: 28))
									.foregroundStyle(.white)

								Text("Текущая станция: \(currentStation?.name ?? "Не выбрана")")
									.font(.custom("Montserrat-Regular", size: 20))
									.foregroundStyle(.white)
							}

							Spacer()

							NavigationLink {
								InventoryView()
									.environmentObject(session)
							} label: {
								Image(systemName: "shippingbox.fill")
									.font(.system(size: 20, weight: .bold))
									.foregroundStyle(.white)
									.padding(12)
									.background(Color.white.opacity(0.16))
									.clipShape(Circle())
							}
						}

						Text("Баланс: \(formattedBalance)")
							.font(.custom("Montserrat-Regular", size: 18))
							.foregroundStyle(.white)

						if let tradeMessage {
							Text(tradeMessage)
								.font(.custom("Montserrat-Regular", size: 14))
								.foregroundStyle(.white)
								.padding()
								.frame(maxWidth: .infinity, alignment: .leading)
								.background(Color.white.opacity(0.12))
								.clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
						}

						TradeSectionView(
							title: "Покупка на этой станции",
							subtitle: currentStation == nil
							? "Сначала выберите станцию"
							: "Уникальные товары станции \(currentStation?.name ?? "")",
							items: goodsForSaleAtCurrentStation,
							accentColor: .green,
							actionTitle: "Купить",
							quantityProvider: { item in
								session.quantityInInventory(for: item.id)
							},
							isActionDisabled: { item in
								currentStation == nil ||
								isTradeInProgress ||
								(session.balance ?? 0) < Double(item.price)
							},
							action: buy
						)

						TradeSectionView(
							title: "Продажа на этой станции",
							subtitle: currentStation == nil
							? "Нет доступных товаров"
							: "Здесь можно продавать товары, купленные на других станциях",
							items: goodsYouCanSellHere,
							accentColor: .orange,
							actionTitle: "Продать",
							quantityProvider: { item in
								session.quantityInInventory(for: item.id)
							},
							priceProvider: { item in
								guard let station = currentStation else { return item.price }
								return session.sellPrice(for: item, at: station)
							},
							isActionDisabled: { item in
								currentStation == nil ||
								isTradeInProgress ||
								session.quantityInInventory(for: item.id) <= 0
							},
							action: sell
						)
					}
					.padding(20)
				}
			}
			.task {
				await session.refreshInventory()
				await session.refreshUpgrades()
			}
		}
	}
	
	private func buy(_ item: TradeItem) {
		guard let station = currentStation else { return }
		
		isTradeInProgress = true
		tradeMessage = nil
		
		Task { @MainActor in
			do {
				try await session.buy(item, at: station)
				tradeMessage = "Куплено: \(item.name)"
			} catch {
				tradeMessage = error.localizedDescription
			}
			
			isTradeInProgress = false
		}
	}
	
	private func sell(_ item: TradeItem) {
		guard let station = currentStation else { return }
		
		isTradeInProgress = true
		tradeMessage = nil
		
		Task { @MainActor in
			do {
				try await session.sell(item, at: station)
				tradeMessage = "Продано: \(item.name)"
			} catch {
				tradeMessage = error.localizedDescription
			}
			
			isTradeInProgress = false
		}
	}
}
