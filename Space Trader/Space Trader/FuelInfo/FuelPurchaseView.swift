import SwiftUI

struct FuelPurchaseView: View {
	@EnvironmentObject private var session: SessionStore
	@Environment(\.dismiss) private var dismiss

	@State private var selectedAmount = 25
	@State private var isBuying = false
	@State private var errorMessage: String?

	private let fuelPrice = 8
	private let amounts = [10, 25, 50]

	var availableToBuy: Int {
		max(0, session.maxFuel - session.fuel)
	}

	var finalAmount: Int {
		min(selectedAmount, availableToBuy)
	}

	var finalPrice: Int {
		finalAmount * fuelPrice
	}

	var fullShipPrice: Int {
		availableToBuy * fuelPrice
	}

	var canBuy: Bool {
		finalAmount > 0 && (session.balance ?? 0) >= Double(finalPrice) && !isBuying
	}

	var canBuyFullShip: Bool {
		availableToBuy > 0 && (session.balance ?? 0) >= Double(fullShipPrice) && !isBuying
	}

	var body: some View {
		NavigationStack {
			ZStack {
				Color.black.ignoresSafeArea()

				VStack(alignment: .leading, spacing: 18) {
					Text("Тариф топлива")
						.font(.custom("Montserrat-Bold", size: 28))
						.foregroundStyle(.white)

					Text("Сейчас: \(session.fuel)/\(session.maxFuel). 1 ед. топлива = \(fuelPrice)$")
						.font(.custom("Montserrat-Regular", size: 16))
						.foregroundStyle(.white.opacity(0.75))

					LazyVGrid(
						columns: [
							GridItem(.flexible()),
							GridItem(.flexible()),
							GridItem(.flexible())
						],
						spacing: 12
					) {
						ForEach(amounts, id: \.self) { amount in
							Button {
								selectedAmount = amount
							} label: {
								VStack(spacing: 6) {
									Text("+\(amount)")
										.font(.custom("Montserrat-Bold", size: 22))

									Text("\(amount * fuelPrice)$")
										.font(.custom("Montserrat-Regular", size: 14))
								}
								.frame(maxWidth: .infinity)
								.padding(.vertical, 18)
								.background(
									amount == selectedAmount
									? Color.white
									: Color.white.opacity(0.14)
								)
								.foregroundStyle(
									amount == selectedAmount
									? .black
									: .white
								)
								.clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
							}
							.buttonStyle(.plain)
						}
					}

					Button {
						selectedAmount = availableToBuy
					} label: {
						HStack {
							VStack(alignment: .leading, spacing: 4) {
								Text("Залить до полного")
									.font(.custom("Montserrat-Bold", size: 18))

								Text("+\(availableToBuy) топлива за \(fullShipPrice)$")
									.font(.custom("Montserrat-Regular", size: 14))
									.opacity(0.75)
							}

							Spacer()

							Image(systemName: "fuelpump.fill")
								.font(.system(size: 22, weight: .semibold))
						}
						.padding(16)
						.frame(maxWidth: .infinity)
						.background(
							selectedAmount == availableToBuy && availableToBuy > 0
							? Color.white
							: Color.white.opacity(0.14)
						)
						.foregroundStyle(
							selectedAmount == availableToBuy && availableToBuy > 0
							? .black
							: .white
						)
						.clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
					}
					.buttonStyle(.plain)
					.disabled(availableToBuy <= 0)

					Text("К покупке: +\(finalAmount) за \(finalPrice)$")
						.font(.custom("Montserrat-Regular", size: 17))
						.foregroundStyle(.white)

					if let errorMessage {
						Text(errorMessage)
							.font(.custom("Montserrat-Regular", size: 15))
							.foregroundStyle(.red)
					}

					Button {
						buy()
					} label: {
						Text(isBuying ? "Покупаем..." : "Купить топливо")
							.font(.custom("Montserrat-Bold", size: 18))
							.frame(maxWidth: .infinity)
							.padding(.vertical, 14)
							.background(canBuy ? Color.white : Color.gray.opacity(0.45))
							.foregroundStyle(.black)
							.clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
					}
					.disabled(!canBuy)

					Spacer()
				}
				.padding(24)
			}
			.toolbar {
				ToolbarItem(placement: .topBarTrailing) {
					Button("Закрыть") {
						dismiss()
					}
				}
			}
		}
	}

	private func buy() {
		guard canBuy else { return }

		errorMessage = nil
		isBuying = true

		Task { @MainActor in
			do {
				try await session.buyFuel(amount: finalAmount)
				dismiss()
			} catch {
				errorMessage = error.localizedDescription
			}

			isBuying = false
		}
	}
}
