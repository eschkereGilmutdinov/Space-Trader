import SwiftUI

struct LeaderboardRowView: View {
	let place: Int
	let username: String
	let valueText: String
	
	private var backgroundColor: Color {
		switch place {
		case 1:
			return Color(red: 1.0, green: 0.75, blue: 0.18).opacity(0.92)
		case 2:
			return Color(red: 0.75, green: 0.78, blue: 0.82).opacity(0.9)
		case 3:
			return Color(red: 0.74, green: 0.45, blue: 0.24).opacity(0.9)
		default:
			return Color.white.opacity(0.14)
		}
	}
	
	private var foregroundColor: Color {
		place <= 3 ? .black : .white
	}
	
	var body: some View {
		HStack(spacing: 14) {
			Text("\(place)")
				.font(.custom("Montserrat-Bold", size: 16))
				.foregroundStyle(foregroundColor.opacity(0.78))
				.frame(width: 28)
			
			VStack(alignment: .leading, spacing: 4) {
				Text(username)
					.font(.custom("Montserrat-Regular", size: 18))
					.foregroundStyle(foregroundColor)
				
				Text(valueText)
					.font(.custom("Montserrat-Regular", size: 18))
					.foregroundStyle(foregroundColor)
			}
			
			Spacer()
		}
		.padding(.horizontal, 18)
		.padding(.vertical, 14)
		.background(backgroundColor)
		.clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
		.overlay {
			RoundedRectangle(cornerRadius: 18, style: .continuous)
				.stroke(Color.white.opacity(place <= 3 ? 0.45 : 0.12), lineWidth: 1)
		}
	}
}
