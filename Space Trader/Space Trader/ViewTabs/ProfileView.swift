import SwiftUI

struct ProfileView: View {
	@EnvironmentObject var sessionStore: SessionStore
	private let backgroundImageName = "ProfileBackground"
	
	var body: some View {
		ZStack {
			Image(backgroundImageName)
				.resizable()
				.scaledToFill()
				.ignoresSafeArea()
			
			Color.black.opacity(0.35)
				.ignoresSafeArea()
			
			ScrollView {
				VStack(spacing: 20) {
					ProfileHeaderView(
						username: sessionStore.username,
						userId: sessionStore.userId
					)
					.environmentObject(sessionStore)
					ProfileStatsCardView(
						level: sessionStore.displayedLevel,
						currentLevelExperience: sessionStore.currentLevelExperience,
						nextLevelExperience: sessionStore.nextLevelExperience,
						currentLevelProgress: sessionStore.currentLevelProgress,
						balance: sessionStore.balance ?? 0
					)
					LogoutButtonView{
						Task {
							await sessionStore.logout()
						}
					}
				}
				.padding(.horizontal, 20)
				.padding(.top, 40)
				.padding(.bottom, 24)
			}
			.frame(maxWidth: .infinity, maxHeight: .infinity)
			.refreshable {
				try? await sessionStore.refreshProfile()
			}
		}
	}
}
