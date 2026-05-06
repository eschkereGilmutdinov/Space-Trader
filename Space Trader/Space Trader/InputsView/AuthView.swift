import SwiftUI

struct AuthView: View {
	@State private var mode: Mode = .login
	private let backgroundAuthView = "AuthBackground"
	
	enum Mode {
		case login
		case register
	}
	
	var body: some View {
		ZStack {
			Image(backgroundAuthView)
				.resizable()
				.scaledToFill()
				.ignoresSafeArea()
			if mode == .login {
				LoginView {
					mode = .register
				}
			} else {
				RegisterView {
					mode = .login
				}
			}
		}
	}
}
