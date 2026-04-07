import SwiftUI

struct ContentView: View {
	@EnvironmentObject var session: SessionStore

	enum Tab {
		case home
		case trade
		case upgrade
		case profile
	}

	@State private var selectedTab: Tab = .home

	var body: some View {
		Group {
			if session.isChecking {
				ProgressView("Проверка сессии...")
			} else if session.isLoggedIn {
				TabView(selection: $selectedTab) {
					StationView()
						.tabItem {
							Label("Станции", systemImage: "house")
						}
						.tag(Tab.home)

					TradeView()
						.tabItem {
							Label("Торговля", systemImage: "cart")
						}
						.tag(Tab.trade)

					UpgradeView()
						.tabItem {
							Label("Улучшения", systemImage: "globe")
						}
						.tag(Tab.upgrade)

					ProfileView()
						.tabItem {
							Label("Профиль", systemImage: "person")
						}
						.tag(Tab.profile)
				}
			} else {
				AuthView()
			}
		}
	}
}

#Preview {
	ContentView()
		.environmentObject(SessionStore())
}
