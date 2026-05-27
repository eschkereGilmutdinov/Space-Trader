import SwiftUI

struct ContentView: View {
	@EnvironmentObject var session: SessionStore

	enum Tab {
		case home
		case trade
		case upgrade
		case profile
		case leaderboard
	}

	@State private var selectedTab: Tab = .home

	var body: some View {
		Group {
			if session.isChecking {
				ProgressView("Проверка сессии...")
			} else if session.isLoggedIn {
				TabView(selection: $selectedTab) {
					UpgradeView()
						.tabItem {
							Label("Улучшения", systemImage: "globe")
						}
						.tag(Tab.upgrade)

					TradeView()
						.tabItem {
							Label("Торговля", systemImage: "cart")
						}
						.tag(Tab.trade)
					
					StationView()
						.tabItem {
							Label("Станции", systemImage: "house")
						}
						.tag(Tab.home)
					
					LeaderboardView()
						.tabItem {
							Label("Рейтинг", systemImage: "trophy")
						}
						.tag(Tab.leaderboard)

					ProfileView()
						.tabItem {
							Label("Профиль", systemImage: "person")
						}
						.tag(Tab.profile)
				}
				.preferredColorScheme(.dark)
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
