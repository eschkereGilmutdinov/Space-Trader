import SwiftUI

struct LogoutButtonView: View {
	let action: () -> Void
	
	@State private var showLogoutConfirmation = false
	
	var body: some View {
		Button(role: .destructive) {
			showLogoutConfirmation = true
		} label: {
			Text("Выйти")
				.font(.custom("Montserrat-Regular", size: 15))
				.frame(maxWidth: .infinity)
				.padding()
				.background(Color.red)
				.foregroundStyle(.white)
				.cornerRadius(14)
		}
		.alert("Выйти из аккаунта?", isPresented: $showLogoutConfirmation) {
			Button("Отмена", role: .cancel) { }
			Button("Выйти", role: .destructive) {
				action()
			}
		} message: {
			Text("Вы уверены, что хотите выйти?")
		}
	}
}
