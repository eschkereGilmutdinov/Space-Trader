import SwiftUI

struct UpgradeInfoView: View {
	var body: some View {
		Text("Улучшение прибыли влияет на итоговую цену продажи на разных станциях.")
			.font(.custom("Montserrat-Regular", size: 14))
			.foregroundStyle(.white.opacity(0.75))
			.padding()
			.frame(maxWidth: .infinity, alignment: .leading)
			.background(Color.white.opacity(0.10))
			.clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
	}
}
