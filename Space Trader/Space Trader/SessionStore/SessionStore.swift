import Foundation
import SwiftUI
import Combine

@MainActor
final class SessionStore: ObservableObject {
	@Published var token: String?
	@Published var userId: String?
	@Published var username: String?
	@Published var level: Int?
	@Published var experience: Int?
	@Published var balance: Double?
	@Published var isChecking = true
	@Published var avatarImage: UIImage?
	@Published var currentStationID: String
	@Published var inventory: [InventoryItem] = []
	@Published var upgrades = UserUpgradesResponse(speedLevel: 0, profitLevel: 0, fuelEfficiencyLevel: 0, durabilityLevel: 0, maxLevel: 10, speedCost: 300, profitCost: 300, fuelEfficiencyCost: 300, durabilityCost: 300)
	
	private let tokenKey = "sessionToken"
	private let userIdKey = "userId"
	private let usernameKey = "username"
	private let levelKey = "level"
	private let experienceKey = "experience"
	private let balanceKey = "balance"
	private let currentStationKey = "currentStation"
	
	private let experiencePerLevel = 500
	
	init() {
		token = UserDefaults.standard.string(forKey: tokenKey)
		userId = UserDefaults.standard.string(forKey: userIdKey)
		username = UserDefaults.standard.string(forKey: usernameKey)
		
		let savedLevel = UserDefaults.standard.object(forKey: levelKey) as? Int
		let savedExperience = UserDefaults.standard.object(forKey: experienceKey) as? Int
		let savedBalance = UserDefaults.standard.object(forKey: balanceKey) as? Double
		let savedStation = UserDefaults.standard.string(forKey: currentStationKey)
		
		level = savedLevel ?? 1
		experience = savedExperience ?? 0
		balance = savedBalance ?? 1000
		currentStationID = savedStation ?? stations.first?.id ?? ""
		
		loadAvatarFromDisk()
	}
	
	var isLoggedIn: Bool {
		token != nil
	}
	
	var currentStation: Station? {
		stations.first(where: { $0.id == currentStationID})
	}
	
	func moveToStation(_ station: Station) {
		currentStationID = station.id
		UserDefaults.standard.set(station.id, forKey: currentStationKey)
	}
	
	var currentLevelProgress: Double {
		let exp = experience ?? 0
		let clamped = max(0, exp % experiencePerLevel)
		return Double(clamped) / Double(experiencePerLevel)
	}

	var currentLevelExperience: Int {
		let exp = experience ?? 0
		return max(0, exp % experiencePerLevel)
	}
	
	var nextLevelExperience: Int {
		experiencePerLevel
	}
	
	var displayedLevel: Int {
		level ?? 1
	}
	
	func refreshUpgrades() async {
		guard let token else { return }
		
		do {
			upgrades = try await APIClient.shared.upgrades(token: token)
		} catch {
			print("Failed to refresh upgrades", error.localizedDescription)
		}
	}
	
	func buyUpgrades(type: String) async throws {
		guard let token else { return }
		
		let response = try await APIClient.shared.buyUpgrades(token: token, type: type)
		apply(me: response.user)
		upgrades = response.upgrades
	}
	
	func refreshInventory() async {
		guard let token else { return }
		
		do {
			let response = try await APIClient.shared.inventory(token: token)
			inventory = response.items
		} catch {
			print("Failed to refresh inventory", error.localizedDescription)
		}
	}
	
	func buy(_ item: TradeItem, at station: Station) async throws {
		guard let token else { return }
		
		let response = try await APIClient.shared.buy(token: token, stationId: station.id, itemId: item.id)
		apply(me: response.user)
		inventory = response.inventory.items
	}
	
	func sell(_ item: TradeItem, at station: Station) async throws {
		guard let token else { return }
		
		let response = try await APIClient.shared.sell(token: token, stationId: station.id, itemId: item.id)
		apply(me: response.user)
		inventory = response.inventory.items
	}
	
	func quantityInInventory(for itemID: String) -> Int {
		inventory.first(where: { $0.itemId == itemID })?.quantity ?? 0
	}
	
	func addExperince(_ amount: Int) async {
		guard let token else { return }
		
		let newExperience = (experience ?? 0) + amount
		
		do {
			let me = try await APIClient.shared.updateExperience(
				token: token,
				experience: newExperience
			)
			apply(me: me)
		} catch {
			print("Failed to update experience:", error.localizedDescription)
		}
	}
	
	func bootstrap() async {
		guard token != nil else {
			isChecking = false
			return
		}
		
		do {
			try await refreshProfile()
		} catch {
			clear()
		}
		
		isChecking = false
	}
	
	func refreshProfile() async throws {
		guard let token else { return }
		let me = try await APIClient.shared.me(token: token)
		apply(me: me)
		
		await refreshInventory()
		await refreshUpgrades()
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
		level = nil
		experience = nil
		balance = nil
		inventory = []
		upgrades = UserUpgradesResponse(speedLevel: 0, profitLevel: 0, fuelEfficiencyLevel: 0, durabilityLevel: 0, maxLevel: 10, speedCost: 300, profitCost: 300, fuelEfficiencyCost: 300, durabilityCost: 300)
		
		UserDefaults.standard.removeObject(forKey: tokenKey)
		UserDefaults.standard.removeObject(forKey: userIdKey)
		UserDefaults.standard.removeObject(forKey: usernameKey)
		UserDefaults.standard.removeObject(forKey: levelKey)
		UserDefaults.standard.removeObject(forKey: experienceKey)
		UserDefaults.standard.removeObject(forKey: balanceKey)
	}
	
	func saveAvatar(_ image: UIImage) throws {
		guard let userId else {
			throw NSError(domain: "AvatarError", code: 1, userInfo: [
				NSLocalizedDescriptionKey: "User ID not found"
			])
		}
		let fileName = "avatar_\(userId).jpg"
		let url = try avatarURL(fileName: fileName)
		
		guard let data = image.jpegData(compressionQuality: 0.85) else {
			throw NSError(domain: "AvatarError", code: 2, userInfo: [
				NSLocalizedDescriptionKey: "Failed to encode image"
			])
		}
		
		try data.write(to: url, options: .atomic)
		avatarImage = image
	}
	
	func removeAvatar() {
		guard let userId else {
			avatarImage = nil
			return
		}
		
		let fileName = "avatar_\(userId).jpg"
		
		if let url = try? avatarURL(fileName: fileName) {
			try? FileManager.default.removeItem(at: url)
		}
		
		avatarImage = nil
	}
	
	func loadAvatarFromDisk() {
		guard let userId else {
			avatarImage = nil
			return
		}
		
		let fileName = "avatar_\(userId).jpg"
		
		guard
			let url = try? avatarURL(fileName: fileName),
			let data = try? Data(contentsOf: url),
			let image = UIImage(data: data)
		else {
			avatarImage = nil
			return
		}
		
		avatarImage = image
	}
	
	private let stationDemandMultipliers: [String: [String: Double]] = [
		"alpha-orbital": [
			"beta-port": 0.82,
			"gamma-transit": 1.05,
			"delta-science": 1.38,
			"epsilon-outpost": 0.94
		],

		"beta-port": [
			"alpha-orbital": 1.22,
			"gamma-transit": 0.88,
			"delta-science": 1.31,
			"epsilon-outpost": 1.08
		],

		"gamma-transit": [
			"alpha-orbital": 0.91,
			"beta-port": 1.16,
			"delta-science": 0.79,
			"epsilon-outpost": 1.34
		],

		"delta-science": [
			"alpha-orbital": 1.42,
			"beta-port": 0.86,
			"gamma-transit": 1.12,
			"epsilon-outpost": 0.76
		],

		"epsilon-outpost": [
			"alpha-orbital": 0.84,
			"beta-port": 1.19,
			"gamma-transit": 0.93,
			"delta-science": 1.48
		]
	]
	
	func sellPrice(for item: TradeItem, at station: Station) -> Int {
		let sourceStationId = stations.first {
			$0.tradeItems.contains { $0.id == item.id }
		}?.id ?? ""

		let demandMultiplier = stationDemandMultipliers[sourceStationId]?[station.id] ?? 0.95
		let profitBonus = Double(upgrades.profitLevel) * 0.08

		let adjustedMultiplier: Double
		if demandMultiplier < 1.0 {
			adjustedMultiplier = demandMultiplier + profitBonus * 0.35
		} else {
			adjustedMultiplier = demandMultiplier + profitBonus
		}

		return max(1, Int((Double(item.price) * adjustedMultiplier).rounded()))
	}
	
	private func avatarURL(fileName: String) throws -> URL {
		let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
		return documents.appendingPathComponent(fileName)
	}
	
	private func apply(me: MeResponse) {
		userId = me.userId.uuidString
		username = me.username
		level = me.level
		experience = me.experience
		balance = me.balance
		
		UserDefaults.standard.set(me.userId.uuidString, forKey: userIdKey)
		UserDefaults.standard.set(me.username, forKey: usernameKey)
		UserDefaults.standard.set(me.level, forKey: levelKey)
		UserDefaults.standard.set(me.experience, forKey: experienceKey)
		UserDefaults.standard.set(me.balance, forKey: balanceKey)
		
		loadAvatarFromDisk()
	}
}
