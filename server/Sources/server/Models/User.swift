import Fluent
import Vapor

final class User: Model, Content {
	static let schema = "users"
	
	@ID(key: .id)
	var id: UUID?
	
	@Field(key: "username")
	var username: String
	
	@Field(key: "password_hash")
	var passwordHash: String
	
	@Timestamp(key: "created_at", on: .create)
	var createdAt: Date?
	
	@Field(key: "level")
	var level: Int
	
	@Field(key: "experience")
	var experience: Int
	
	@Field(key: "balance")
	var balance: Double
	
	@Field(key: "fuel")
	var fuel: Int
	
	@Field(key: "current_station_id")
	var currentStationID: String
	
	@Field(key: "speed_upgrade_level")
	var speedUpgradeLevel: Int
	
	@Field(key: "profit_upgrade_level")
	var profitUpgradeLevel: Int
	
	@Field(key: "fuel_efficiency_upgrade_level")
	var fuelEfficiencyUpgradeLevel: Int
	
	@Field(key: "durability_upgrade_level")
	var durabilityUpgradeLevel: Int
	
	init() {}
	
	init(id: UUID? = nil, username: String, passwordHash: String, level: Int = 1, experience: Int = 0, balance: Double = 1000, fuel: Int = 100, currentStationID: String = "alpha-orbital", speedUpgradeLevel: Int = 0, profitUpgradeLevel: Int = 0, fuelEfficiencyUpgradeLevel: Int = 0, durabilityUpgradeLevel: Int = 0) {
		self.id = id
		self.username = username
		self.passwordHash = passwordHash
		self.level = level
		self.experience = experience
		self.balance = balance
		self.fuel = fuel
		self.currentStationID = currentStationID
		self.speedUpgradeLevel = speedUpgradeLevel
		self.profitUpgradeLevel = profitUpgradeLevel
		self.fuelEfficiencyUpgradeLevel = fuelEfficiencyUpgradeLevel
		self.durabilityUpgradeLevel = durabilityUpgradeLevel
	}
}

extension User: @unchecked Sendable {}
