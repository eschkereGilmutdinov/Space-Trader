import SwiftUI

@main
struct Space_TraderApp: App {
	@StateObject private var session = SessionStore()

	var body: some Scene {
		WindowGroup {
			ContentView()
				.environmentObject(session)
				.task {
					await session.bootstrap()
				}
		}
	}
}
