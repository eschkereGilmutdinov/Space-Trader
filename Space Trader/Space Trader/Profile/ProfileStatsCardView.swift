import SwiftUI

struct ProfileStatsCardView: View {
	let level: Int
	let currentLevelExperience: Int
	let nextLevelExperience: Int
	let currentLevelProgress: Double
	let balance: Double
	
	var body: some View {
		VStack(alignment: .leading, spacing: 18) {
			HStack {
				Label("Уровень", systemImage: "star.fill")
					.foregroundStyle(.white)
					.font(.custom("Montserrat-Regular", size: 18))
				Spacer()
				Text("\(level)")
					.font(.custom("Montserrat-Regular", size: 20))
					.foregroundStyle(.white)
			}
			
			VStack(alignment: .leading, spacing: 8) {
				HStack {
					Label("Опыт", systemImage: "char.bar.fill")
						.foregroundStyle(.white)
						.font(.custom("Montserrat-Regular", size: 18))
					Spacer()
					Text("\(currentLevelExperience)/\(nextLevelExperience)")
						.font(.custom("Montserrat-Regular", size: 20))
						.foregroundStyle(.white.opacity(0.9))
				}
				
				ProgressView(value: currentLevelProgress)
					.progressViewStyle(.linear)
					.tint(.green)
					.scaleEffect(x: 1, y: 1.8, anchor: .center)
			}
			
			HStack {
				Label("Баланс", systemImage: "creditcard.fill")
					.foregroundStyle(.white)
					.font(.custom("Montserrat-Regular", size: 18))
				Spacer()
				Text("\(Int(balance).formatted())$")
					.font(.custom("Montserrat-Regular", size: 20))
					.foregroundStyle(.yellow)
			}
		}
		.padding(20)
		.frame(maxWidth: .infinity)
		.background(.ultraThinMaterial)
		.cornerRadius(24)
	}
}
