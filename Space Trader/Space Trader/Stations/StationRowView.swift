import SwiftUI

struct TextRow: View {
	let station: Station
	let color045 = Color(red: 0.953, green: 0.969, blue: 1.0)
	let color10 = Color(red: 0.812, green: 0.902, blue: 1.0)
	
	init(station: Station) {
		self.station = station
	}
	
	var body: some View {
		Text(station.name)
			.font(.custom("Montserrat-Regular", size: 20))
			.foregroundStyle(
				LinearGradient(
					stops: [
						.init(color: .white, location: 0.0),
						.init(color: color045, location: 0.45),
						.init(color: color10, location: 1.0)
					],
					startPoint: .topLeading,
					endPoint: .bottomTrailing
				)
			)
			.tracking(0.4)
			.bold()
	}
}

struct ImageRow: View {
	let station: Station
	
	init(station: Station) {
		self.station = station
	}
	
	var body: some View {
		Image(station.imageName ?? "globe")
			.resizable()
			.scaledToFit()
			.frame(width: 110, height: 110)
			.clipShape(RoundedRectangle(cornerRadius: 12))

	}
}
