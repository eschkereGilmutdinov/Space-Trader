import SwiftUI

struct RouteFuelInfoView: View {
	@EnvironmentObject private var session: SessionStore
	let station: Station

	var body: some View {
		HStack(spacing: 12) {
			Image(systemName: "fuelpump.fill")
				.foregroundStyle(.white)

			VStack(alignment: .leading, spacing: 4) {
				if session.currentStationID == station.id {
					Text("Текущая станция")
						.foregroundStyle(.white)
				} else if let cost = session.effectiveFuelCost(to: station) {
					Text("Стоимость перелёта: \(cost) топлива")
						.foregroundStyle(.white)

					Text("На борту: \(session.fuel)/\(session.maxFuel)")
						.foregroundStyle(.white.opacity(0.7))
				} else {
					Text("Прямого маршрута нет")
						.foregroundStyle(.white)

					Text("Выбери соседнюю станцию по графу")
						.foregroundStyle(.white.opacity(0.7))
				}
			}
			.font(.custom("Montserrat-Regular", size: 16))

			Spacer()
		}
		.padding()
		.frame(maxWidth: .infinity)
		.background(Color.white.opacity(0.12))
		.clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
	}
}
