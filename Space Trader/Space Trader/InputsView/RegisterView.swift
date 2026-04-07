import SwiftUI

struct RegisterView: View {
	@EnvironmentObject var session: SessionStore

	@State private var username = ""
	@State private var password = ""
	@State private var errorText: String?
	@State private var isLoading = false

	var body: some View {
		VStack(spacing: 12) {
			TextField("Username", text: $username)
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

			Button(isLoading ? "Регистрация..." : "Создать аккаунт") {
				Task { await submit() }
			}
			.buttonStyle(.borderedProminent)
			.disabled(isLoading || username.isEmpty || password.count < 4)
		}
	}

	@MainActor
	private func submit() async {
		isLoading = true
		errorText = nil

		do {
			let auth = try await APIClient.shared.register(
				username: username,
				password: password
			)
			session.save(auth: auth)
		} catch {
			errorText = error.localizedDescription
		}

		isLoading = false
	}
}
