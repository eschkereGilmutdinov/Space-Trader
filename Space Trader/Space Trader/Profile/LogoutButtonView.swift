import SwiftUI

struct LogoutButtonView: View {
	let action: () -> Void
	
	var body: some View {
		Button(role: .destructive, action: action) {
			Text("Выйти")
				.font(.custom("Montserrat-Regular", size: 15))
				.frame(maxWidth: .infinity)
				.padding()
				.background(Color.red)
				.foregroundColor(.white)
				.cornerRadius(14)
		}
	}
}
