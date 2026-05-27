import SwiftUI

struct StationCardView: View {
	let station: Station
	let index: Int
	let isCurrentStation: Bool
	let namespace: Namespace.ID

	var body: some View {
		ZStack(alignment: .topTrailing) {
			content
				.padding(.horizontal, 28)
				.padding(.vertical, 12)
				.frame(maxWidth: .infinity, minHeight: 180)
				.background(cardBackground)
				.overlay(cardBorder)
				.shadow(
					color: isCurrentStation ? Color.green.opacity(0.45) : Color.clear,
					radius: 16
				)
				.contentShape(RoundedRectangle(cornerRadius: 34, style: .continuous))

			if isCurrentStation {
				currentStationBadge
			}
		}
	}

	private var content: some View {
		HStack {
			if index % 2 == 0 {
				TextRow(station: station)
				Spacer()
				ImageRow(station: station)
					.matchedTransitionSource(id: station.id, in: namespace)
			} else {
				ImageRow(station: station)
					.matchedTransitionSource(id: station.id, in: namespace)
				Spacer()
				TextRow(station: station)
			}
		}
	}

	private var cardBackground: some View {
		RoundedRectangle(cornerRadius: 34, style: .continuous)
			.fill(
				isCurrentStation
				? Color.green.opacity(0.25)
				: Color.white.opacity(0.16)
			)
	}

	private var cardBorder: some View {
		RoundedRectangle(cornerRadius: 34, style: .continuous)
			.stroke(
				isCurrentStation ? Color.green : Color.clear,
				lineWidth: 3
			)
	}

	private var currentStationBadge: some View {
		Text("Вы здесь")
			.font(.custom("Montserrat-Bold", size: 13))
			.foregroundStyle(.black)
			.padding(.horizontal, 12)
			.padding(.vertical, 7)
			.background(Color.green)
			.clipShape(Capsule())
			.padding(.top, 12)
			.padding(.trailing, 16)
	}
}
