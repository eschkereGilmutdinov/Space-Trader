import SwiftUI

struct 	LeaderboardView: View {
	@EnvironmentObject private var sessionStore: SessionStore
	
	@State private var selectedRating: RatingType = .level
	@State private var players: [LeaderboardPlayer] = []
	@State private var isLoading = false
	@State private var errorMessage: String?
	
	private var titleView: some View {
		Text("Рейтинг игроков")
			.font(.custom("Montserrat-Regular", size: 30))
			.foregroundStyle(.white)
			.padding(.top, 38)
	}
	
	private var ratingPicker: some View {
		Picker("Тип рейтинга", selection: $selectedRating) {
			ForEach(RatingType.allCases) { type in
				Text(type.title).tag(type)
			}
		}
		.pickerStyle(.segmented)
		.padding(.horizontal, 20)
	}
	
	@ViewBuilder
	private var contentView: some View {
		Group {
			if isLoading {
				ProgressView("Загрузка рейтинга...")
					.tint(.white)
					.foregroundStyle(.white)
			} else if let errorMessage {
				Text(errorMessage)
					.font(.custom("Montserrat-Medium", size: 15))
					.foregroundStyle(.white.opacity(0.85))
					.multilineTextAlignment(.center)
					.padding(20)
			} else {
				playersList
			}
		}
	}
	
	private var playersList: some View {
		ScrollView {
			VStack(spacing: 12) {
				ForEach(Array(players.prefix(10).enumerated()), id: \.element.id) { index, player in
					LeaderboardRowView(place: index + 1, username: player.username, valueText: valueText(for: player))
				}
			}
			.padding(.horizontal, 20)
			.padding(.vertical, 8)
		}
	}
	
	private func valueText(for player: LeaderboardPlayer) -> String {
		switch selectedRating {
		case .level:
			return "Уровень: \(player.level)"
		case .balance:
			return "Деньги: \(player.balance)"
		}
	}
	
	private func loadLeaderboard() async {
		guard let token = sessionStore.token else { return }
		
		isLoading = true
		errorMessage = nil
		
		do {
			let response = try await APIClient.shared.leaderboard(token: token, sort: selectedRating.rawValue)
			players = Array(response.players.prefix(10))
		} catch {
			errorMessage = "Не удалось загрузить рейтинг"
		}
		
		isLoading = false
	}
	
	var body: some View {
		ZStack {
			Color.black.opacity(0.42)
				.ignoresSafeArea()
			
			VStack(spacing: 18) {
				titleView
				ratingPicker
				contentView
			}
		}
		.task {
			await loadLeaderboard()
		}
		.onChange(of: selectedRating) { _, _ in
			Task {
				await loadLeaderboard()
			}
		}
	}
}
