import SwiftUI

struct AuthView: View {
	@State private var mode: Mode = .login

	enum Mode {
		case login
		case register
	}

	var body: some View {
		VStack(spacing: 20) {
			Picker("Mode", selection: $mode) {
				Text("Вход").tag(Mode.login)
				Text("Регистрация").tag(Mode.register)
			}
			.pickerStyle(.segmented)

			if mode == .login {
				LoginView()
			} else {
				RegisterView()
			}
		}
		.padding()
	}
}
