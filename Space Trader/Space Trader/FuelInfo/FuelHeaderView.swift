import SwiftUI

struct FuelHeaderView: View {
	@EnvironmentObject private var session: SessionStore
	@Binding var showFuelShop: Bool

	var body: some View {
		HStack(spacing: 12) {
			Image(systemName: "fuelpump.fill")
				.foregroundStyle(.white)

			Text("\(session.fuel)/\(session.maxFuel)")
				.font(.custom("Montserrat-Bold", size: 18))
				.foregroundStyle(.white)

			ProgressView(value: Double(session.fuel), total: Double(session.maxFuel))
				.tint(.white)

			Button {
				showFuelShop = true
			} label: {
				Image(systemName: "plus")
					.font(.system(size: 15, weight: .bold))
					.foregroundStyle(.black)
					.frame(width: 34, height: 34)
					.background(.white)
					.clipShape(Circle())
			}
			.buttonStyle(.plain)
		}
		.padding(.horizontal, 16)
		.padding(.vertical, 12)
		.background(Color.black.opacity(0.45))
		.clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
	}
}
