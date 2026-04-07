import SwiftUI

struct ProfileView: View {
	@EnvironmentObject var sessionStore: SessionStore
	private let backgroundImageName = "ProfileBackground"
	
    var body: some View {
		HStack {
			ZStack {
				Image(backgroundImageName)
					.resizable()
					.scaledToFit()
					.ignoresSafeArea()
				Button(role: .destructive) {
					Task {
						await sessionStore.logout()
					}
				} label: {
					Text("Выйти")
						.frame(maxWidth: .infinity)
						.padding()
						.background(Color.red)
						.foregroundColor(.white)
						.cornerRadius(12)
				}
				.padding(.horizontal)	
			}
			.padding()
		}
    }
}
