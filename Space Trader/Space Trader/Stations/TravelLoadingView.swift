import SwiftUI

struct TravelLoadingView: View {
	let destinationName: String?
	
	var body: some View {
		ZStack {
			Color.black.ignoresSafeArea()
			
			VStack(spacing: 18) {
				ProgressView()
					.scaleEffect(1.4)
					.tint(.white)
				
				Text("Прокладываем маршрут")
					.font(.custom("Montserrat-Bold", size: 22))
					.foregroundStyle(.white)
				Text("Перелет к станции \(destinationName ?? "")")
					.font(.custom("Montserrat-Regular", size: 16))
					.foregroundStyle(.white.opacity(0.75))
					.multilineTextAlignment(.center)
			}
			.padding(28)
			.frame(maxWidth: 320)
			.background(Color.white.opacity(0.12))
			.clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
		}
	}
}
