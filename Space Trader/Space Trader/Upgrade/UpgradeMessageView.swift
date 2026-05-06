import SwiftUI

struct UpgradeMessageView: View {
	let message: String
	
	var body: some View {
		Text(message)
			.font(.custom("Montserrat-Regular", size: 14))
			.foregroundStyle(.white)
			.padding()
			.frame(maxWidth: .infinity, alignment: .leading)
			.background(Color.white.opacity(0.12))
			.clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous	))
	}
}
