import SwiftUI

struct LoginView: View {
	@EnvironmentObject var session: SessionStore

	@State private var username = ""
	@State private var password = ""
	@State private var errorText: String?
	@State private var isLoading = false
	
	let onRegister: () -> Void

	private let logo = "logo"
	
	var body: some View {
		VStack(spacing: 12) {
			ZStack {
				Image(logo)
					.resizable()
					.scaledToFit()
					.frame(width: 240)
			}
			Text("Вход")
				.foregroundStyle(.white)
				.font(.custom("Montserrat-Regular", size: 50))
				.shadow(color: .black.opacity(0.45), radius: 6, x: 0, y: 3)
				.shadow(color: .white.opacity(0.12), radius: 2, x: 0, y: 0)
			
			TextField("", text: $username)
				.textInputAutocapitalization(.never)
				.autocorrectionDisabled()
				.padding(.horizontal, 16)
				.frame(width: 360, height: 52)
				.background(Color.white.opacity(0.8))
				.foregroundStyle(.black)
				.clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
				.font(.custom("Montserrat-Medium", size: 20))
				.overlay(alignment: .leading, content: {
					if username.isEmpty {
						Text("Username")
							.padding()
							.font(.custom("Montserrat-Medium", size: 20))
							.foregroundStyle(.gray.opacity(0.9))
							.allowsHitTesting(false)
					}
				})

			SecureField("", text: $password)
				.padding(.horizontal, 16)
				.frame(width: 360, height: 52)
				.background(Color.white.opacity(0.8))
				.foregroundStyle(.black)
				.clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
				.font(.custom("Montserrat-Medium", size: 20))
				.overlay(alignment: .leading, content: {
					if password.isEmpty {
						Text("Password")
							.padding()
							.font(.custom("Montserrat-Medium", size: 20))
							.foregroundStyle(.gray.opacity(0.9))
							.allowsHitTesting(false)
					}
				})

			if let errorText {
				Text(errorText)
					.foregroundColor(.red)
					.font(.footnote)
			}

			Button(isLoading ? "Вход..." : "Войти") {
				Task { await submit() }
			}
			.frame(width: 180, height: 50)
			.background(Color.white)
			.foregroundColor(.black)
			.clipShape(Capsule())
			.font(.custom("Montserrat-Regular", size: 18))
			.disabled(isLoading || username.isEmpty || password.isEmpty)
			
			Button("Зарегистрироваться") {
				onRegister()
			}
			.foregroundStyle(.white)
			.padding(.top, 8)
			.font(.custom("Montserrat-Regular", size: 18))
		}
		.padding(15)
		.background(
			RoundedRectangle(cornerRadius: 16, style: .continuous)
				.fill(LinearGradient(
					stops: [
						.init(color: .gray.opacity(0.1), location: 0.0),
						.init(color: .gray.opacity(0.4), location: 0.15),
						.init(color: .gray.opacity(0.6), location: 0.30),
						.init(color: .gray.opacity(0.8), location: 0.50),
						.init(color: .gray.opacity(0.6), location: 0.70),
						.init(color: .gray.opacity(0.4), location: 0.85),
						.init(color: .gray.opacity(0.1), location: 1.0)
					],
					startPoint: .top,
					endPoint: .bottom
				   ))
		)
	}

	@MainActor
	private func submit() async {
		isLoading = true
		errorText = nil

		do {
			let auth = try await APIClient.shared.login(username: username, password: password)
			session.save(auth: auth)
			try await session.refreshProfile()
		} catch {
			errorText = error.localizedDescription
		}

		isLoading = false
	}
}
