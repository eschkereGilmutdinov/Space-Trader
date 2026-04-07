import Foundation
import SwiftUI
import Combine

@MainActor
final class SessionStore: ObservableObject {
	@Published var token: String?
	@Published var userId: String?
	@Published var username: String?
	@Published var isChecking = true
	
	private let tokenKey = "sessionToken"
	private let userIdKey = "userId"
	private let usernameKey = "username"
	
	init() {
		token = UserDefaults.standard.string(forKey: tokenKey)
		userId = UserDefaults.standard.string(forKey: userIdKey)
		username = UserDefaults.standard.string(forKey: usernameKey)
	}
	
	var isLoggedIn: Bool {
		token != nil
	}
	
	func bootstrap() async {
		guard let token else {
			isChecking = false
			return
		}
		do {
			let me = try await APIClient.shared.me(token: token)
			userId = me.userId.uuidString
			username = me.username
			
			UserDefaults.standard.set(me.userId.uuidString, forKey: userIdKey)
			UserDefaults.standard.set(me.username, forKey: usernameKey)
		} catch {
			clear()
		}
		
		isChecking = false
	}
	
	func save(auth: AuthResponse) {
		token = auth.sessionToken
		userId = auth.userId.uuidString
		username = auth.username
		
		UserDefaults.standard.set(auth.sessionToken, forKey: tokenKey)
		UserDefaults.standard.set(auth.userId.uuidString, forKey: userIdKey)
		UserDefaults.standard.set(auth.username, forKey: usernameKey)
	}
	
	func logout() async {
		if let token {
			try? await APIClient.shared.logout(token: token)
		}
		clear()
	}
	
	func clear() {
		token = nil
		userId = nil
		username = nil
		
		UserDefaults.standard.removeObject(forKey: tokenKey)
		UserDefaults.standard.removeObject(forKey: userIdKey)
		UserDefaults.standard.removeObject(forKey: usernameKey)
	}
}
