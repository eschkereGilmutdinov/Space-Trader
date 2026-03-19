import SwiftUI

struct ContentView: View {
    enum Tab {
        case home
        case trade
        case upgrade
        case profile
    }

    @State private var selectedTab: Tab = .home

    var body: some View {
        TabView(selection: $selectedTab) {
            StationView()
                .tabItem {
                    Label("Главная", systemImage: "house")
                }
                .tag(Tab.home)

            TradeView()
                .tabItem {
                    Label("Торговля", systemImage: "cart")
                }
                .tag(Tab.trade)
            UpgradeView()
                .tabItem {
                    Label("Улучшения", systemImage: "upgrade")
                }
                .tag(Tab.upgrade)
            ProfileView()
                .tabItem {
                    Label("Профиль", systemImage: "person")
                }
                .tag(Tab.profile)
        }
    }
}

#Preview {
    ContentView()
}
