import SwiftUI

struct LoginView: View {
	@EnvironmentObject var session: SessionStore

	@State private var username = ""
	@State private var password = ""
	@State private var errorText: String?
	@State private var isLoading = false

	var body: some View {
		VStack(spacing: 12) {
			TextField("UserName", text: $username)
				.textInputAutocapitalization(.never)
				.autocorrectionDisabled()
				.textFieldStyle(.roundedBorder)

			SecureField("Пароль", text: $password)
				.textFieldStyle(.roundedBorder)

			if let errorText {
				Text(errorText)
					.foregroundColor(.red)
					.font(.footnote)
			}

			Button(isLoading ? "Вход..." : "Войти") {
				Task { await submit() }
			}
			.buttonStyle(.borderedProminent)
			.disabled(isLoading || username.isEmpty || password.isEmpty)
		}
	}

	@MainActor
	private func submit() async {
		isLoading = true
		errorText = nil

		do {
			let auth = try await APIClient.shared.login(username: username, password: password)
			session.save(auth: auth)
		} catch {
			errorText = error.localizedDescription
		}

		isLoading = false
	}
}
