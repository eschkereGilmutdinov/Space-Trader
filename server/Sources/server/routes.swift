import Vapor
import Fluent

struct RegisterRequest: Content {
	let username: String
	let password: String
}

struct LoginRequest: Content {
	let username: String
	let password: String
}

struct AuthResponse: Content {
	let userId: UUID
	let username: String
	let sessionToken: String
	let expiresAt: Date
}

struct MeResponse: Content {
	let userId: UUID
	let username: String
	let level: Int
	let experience: Int
	let balance: Double
}

struct InventoryItemResponse: Content {
	let itemId: String
	let name: String
	let description: String
	let price: Int
	let quantity: Int
}

struct InventoryResponse: Content {
	let items: [InventoryItemResponse]
}

struct TradeRequest: Content {
	let stationId: String
	let itemId: String
}

struct TradeResponse: Content {
	let user: MeResponse
	let inventory: InventoryResponse
}

struct UserUpgradesResponse: Content {
	let speedLevel: Int
	let profitLevel: Int
	let fuelEfficiencyLevel: Int
	let durabilityLevel: Int
	let maxLevel: Int
	
	let speedCost: Double?
	let profitCost: Double?
	let fuelEfficiencyCost: Double?
	let durabilityCost: Double?
}

struct UpgradeRequest: Content {
	let type: String
}

struct UpgradePurchaseResponse: Content {
	let user: MeResponse
	let upgrades: UserUpgradesResponse
}

private struct TradeCatalogItem {
	let id: String
	let name: String
	let price: Int
	let description: String
	let stationId: String
}

private let maxUpgradeLevel = 10

private enum UpgradeKind: String, CaseIterable {
	case speed
	case profit
	case fuelEfficiency = "fuel_efficiency"
	case durability
}

private func upgradeCost(forCurrentLevel level: Int) -> Double? {
	guard level < maxUpgradeLevel else { return nil }
	
	let baseCost = 300.0
	let growth = pow(1.45, Double(level))
	
	return (baseCost * growth).rounded()
}

private func upgradesResponse(for user: User) -> UserUpgradesResponse {
	UserUpgradesResponse(
		speedLevel: user.speedUpgradeLevel,
		profitLevel: user.profitUpgradeLevel,
		fuelEfficiencyLevel: user.fuelEfficiencyUpgradeLevel,
		durabilityLevel: user.durabilityUpgradeLevel,
		maxLevel: maxUpgradeLevel,
		speedCost: upgradeCost(forCurrentLevel: user.speedUpgradeLevel),
		profitCost: upgradeCost(forCurrentLevel: user.profitUpgradeLevel),
		fuelEfficiencyCost: upgradeCost(forCurrentLevel: user.fuelEfficiencyUpgradeLevel),
		durabilityCost: upgradeCost(forCurrentLevel: user.durabilityUpgradeLevel)
	)
}

private func level(for kind: UpgradeKind, user: User) -> Int {
	switch kind {
	case .speed:
		return user.speedUpgradeLevel
	case .profit:
		return user.profitUpgradeLevel
	case .fuelEfficiency:
		return user.fuelEfficiencyUpgradeLevel
	case .durability:
		return user.durabilityUpgradeLevel
	}
}

private func increaseLevel(for kind: UpgradeKind, user: User) {
	switch kind {
	case .speed:
		user.speedUpgradeLevel += 1
	case .profit:
		user.profitUpgradeLevel += 1
	case .fuelEfficiency:
		user.fuelEfficiencyUpgradeLevel += 1
	case .durability:
		user.durabilityUpgradeLevel += 1
	}
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

private func sellPrice(for item: TradeCatalogItem, at sellStationId: String, profitLevel: Int) -> Int {
	let demandMultiplier = stationDemandMultipliers[item.stationId]?[sellStationId] ?? 0.95
	let profitBonus = Double(profitLevel) * 0.08

	let adjustedMultiplier: Double
	if demandMultiplier < 1.0 {
		adjustedMultiplier = demandMultiplier + profitBonus * 0.35
	} else {
		adjustedMultiplier = demandMultiplier + profitBonus
	}

	let rawPrice = Double(item.price) * adjustedMultiplier
	return max(1, Int(rawPrice.rounded()))
}

private let tradeCatalog: [TradeCatalogItem] = [
	TradeCatalogItem(id: "alpha-fuel", name: "Орбитальное топливо", price: 120, description: "Стандартное топливо для дальних перелётов.", stationId: "alpha-orbital"),
	TradeCatalogItem(id: "alpha-alloy", name: "Титановый сплав", price: 340, description: "Надёжный конструкционный материал.", stationId: "alpha-orbital"),
	TradeCatalogItem(id: "alpha-nav", name: "Навигационный модуль", price: 520, description: "Модуль для точных межсекторных прыжков.", stationId: "alpha-orbital"),

	TradeCatalogItem(id: "beta-water", name: "Очищенная вода", price: 60, description: "Базовый ресурс для дальних маршрутов.", stationId: "beta-port"),
	TradeCatalogItem(id: "beta-food", name: "Пищевые контейнеры", price: 95, description: "Долговременные пайки для экипажа.", stationId: "beta-port"),
	TradeCatalogItem(id: "beta-bio", name: "Биоматериалы", price: 210, description: "Органические компоненты для лабораторий и медблоков.", stationId: "beta-port"),

	TradeCatalogItem(id: "gamma-drones", name: "Сервисные дроны", price: 410, description: "Компактные дроны для ремонта и логистики.", stationId: "gamma-transit"),
	TradeCatalogItem(id: "gamma-parts", name: "Запчасти класса C", price: 190, description: "Универсальные компоненты для корабельных систем.", stationId: "gamma-transit"),
	TradeCatalogItem(id: "gamma-crates", name: "Грузовые контейнеры", price: 150, description: "Контейнеры для безопасной перевозки товаров.", stationId: "gamma-transit"),

	TradeCatalogItem(id: "delta-meds", name: "Медицинские наниты", price: 630, description: "Продвинутые системы восстановления и лечения.", stationId: "delta-science"),
	TradeCatalogItem(id: "delta-crystals", name: "Квантовые кристаллы", price: 880, description: "Редкий компонент для высокоточных систем.", stationId: "delta-science"),
	TradeCatalogItem(id: "delta-scans", name: "Сканирующая матрица", price: 540, description: "Аппаратный модуль для научных сенсоров.", stationId: "delta-science"),

	TradeCatalogItem(id: "epsilon-ore", name: "Редкая руда", price: 470, description: "Сырьё с окраинных астероидных полей.", stationId: "epsilon-outpost"),
	TradeCatalogItem(id: "epsilon-relic", name: "Артефакты фронтира", price: 760, description: "Находки с заброшенных колоний.", stationId: "epsilon-outpost"),
	TradeCatalogItem(id: "epsilon-batteries", name: "Энергоячейки", price: 260, description: "Надёжные батареи для автономных систем.", stationId: "epsilon-outpost")
]

private func inventoryResponse(for items: [UserInventoryItem]) -> InventoryResponse {
	InventoryResponse(
		items: items
			.filter { $0.quantity > 0 }
			.sorted { $0.name < $1.name }
			.map {
				InventoryItemResponse(
					itemId: $0.itemID,
					name: $0.name,
					description: $0.itemDescription,
					price: $0.price,
					quantity: $0.quantity
				)
			}
	)
}

private func meResponse(for user: User) throws -> MeResponse {
	MeResponse(
		userId: try user.requireID(),
		username: user.username,
		level: user.level,
		experience: user.experience,
		balance: user.balance
	)
}

private func loadInventory(for user: User, on db: any Database) async throws -> [UserInventoryItem] {
	let userID = try user.requireID()
	
	return try await UserInventoryItem.query(on: db)
		.filter(\UserInventoryItem.$user.$id == userID)
		.all()
}

struct UpdateExperienceRequest : Content {
	let experience: Int
}

private func requireActiveSession(_ req: Request) async throws -> UserSession {
	guard let bearer = req.headers.bearerAuthorization else {
		throw Abort(.unauthorized, reason: "Missing authorization token")
	}

	guard let session = try await UserSession.query(on: req.db)
		.filter(\.$token == bearer.token)
		.with(\.$user)
		.first()
	else {
		throw Abort(.unauthorized, reason: "Invalid session")
	}

	return session
}

private func experienceReward(buyPrice: Int, sellPrice: Int) -> Int {
	let profit = sellPrice - buyPrice
	
	guard profit > 0 else {
		return 0
	}
	
	return max(1, Int((Double(profit) * 0.35).rounded()))
}

func routes(_ app: Application) throws {
	let auth = app.grouped("auth")
	
	auth.get("upgrades") { req async throws -> UserUpgradesResponse in
		let session = try await requireActiveSession(req)
		return upgradesResponse(for: session.user)
	}
	
	auth.post("upgrades", "buy") { req async throws -> UpgradePurchaseResponse in
		let session = try await requireActiveSession(req)
		let data = try req.content.decode(UpgradeRequest.self)
		let user = session.user
		
		guard let kind = UpgradeKind(rawValue: data.type) else {
			throw Abort(.badRequest, reason: "Unknown upgrade type")
		}
		
		let currentLevel = level(for: kind, user: user)
		
		guard let cost = upgradeCost(forCurrentLevel: currentLevel) else {
			throw Abort(.badRequest, reason: "Upgrade is already maxed")
		}
		
		guard user.balance >= cost else {
			throw Abort(.badRequest, reason: "Not enough balance")
		}
		
		user.balance -= cost
		increaseLevel(for: kind , user: user)
		
		try await user.save(on: req.db)
		
		return UpgradePurchaseResponse(user: try meResponse(for: user), upgrades: upgradesResponse(for: user))
	}
	
	auth.get("inventory") { req async throws -> InventoryResponse in
		let session = try await requireActiveSession(req)
		let items = try await loadInventory(for: session.user, on: req.db)
		return inventoryResponse(for: items)
	}
	
	auth.post("trade", "buy") { req async throws -> TradeResponse in
		let session = try await requireActiveSession(req)
		let data = try req.content.decode(TradeRequest.self)
		let user = session.user
		let userID = try user.requireID()
		
		guard let catalogItem = tradeCatalog.first(where: { $0.id == data.itemId }) else {
			throw Abort(.badRequest, reason: "Unknown trade item")
		}
		
		guard catalogItem.stationId == data.stationId else {
			throw Abort(.badRequest, reason: "This item is not sold on this station")
		}
		
		guard user.balance >= Double(catalogItem.price) else {
			throw Abort(.badRequest, reason: "Not enough balance")
		}
		
		user.balance -= Double(catalogItem.price)
		
		let inventoryItem = try await UserInventoryItem.query(on: req.db)
			.filter(\UserInventoryItem.$user.$id == userID)
			.filter(\UserInventoryItem.$itemID == catalogItem.id)
			.first()
		
		if let inventoryItem {
			inventoryItem.quantity += 1
			inventoryItem.name = catalogItem.name
			inventoryItem.itemDescription = catalogItem.description
			inventoryItem.price = catalogItem.price
			
			try await inventoryItem.save(on: req.db)
		} else {
			let newItem = UserInventoryItem (
				userID: userID,
				itemID: catalogItem.id,
				name: catalogItem.name,
				itemDescription: catalogItem.description,
				price: catalogItem.price,
				quantity: 1
			)
			
			try await newItem.save(on: req.db)
		}
		
		try await user.save(on: req.db)
		
		let inventory = try await loadInventory(for: user, on: req.db)
		
		return TradeResponse(
			user: try meResponse(for: user),
			inventory: inventoryResponse(for: inventory)
		)
	}
	
	auth.post("trade", "sell") { req async throws -> TradeResponse in
		let session = try await requireActiveSession(req)
		let data = try req.content.decode(TradeRequest.self)
		let user = session.user
		let userID = try user.requireID()
		
		guard let catalogItem = tradeCatalog.first(where: { $0.id == data.itemId }) else {
			throw Abort(.badRequest, reason: "Unknown trade item")
		}
		
		guard catalogItem.stationId != data.stationId else {
			throw Abort(.badRequest, reason: "This station does not buy its own goods")
		}
		
		guard let inventoryItem = try await UserInventoryItem.query(on: req.db)
			.filter(\UserInventoryItem.$user.$id == userID)
			.filter(\UserInventoryItem.$itemID == catalogItem.id)
			.first(),
			  inventoryItem.quantity > 0
		else {
			throw Abort(.badRequest, reason: "You don't have this item in inventory")
		}
		
		let finalSellPrice = sellPrice(for: catalogItem, at: data.stationId, profitLevel: user.profitUpgradeLevel)
		let gainedExperience = experienceReward(buyPrice: catalogItem.price, sellPrice: finalSellPrice)
		
		inventoryItem.quantity -= 1
		user.balance += Double(finalSellPrice)
		
		if gainedExperience > 0 {
			user.experience += gainedExperience
			user.level = (user.experience / 500) + 1
		}
		
		if inventoryItem.quantity == 0 {
			try await inventoryItem.delete(on: req.db)
		} else {
			try await inventoryItem.save(on: req.db)
		}
		
		try await user.save(on: req.db)
		
		let inventory = try await loadInventory(for: user, on: req.db)
		
		return TradeResponse (
			user: try meResponse(for: user),
			inventory: inventoryResponse(for: inventory)
		)
	}
	
	auth.post("experience") { req async throws -> MeResponse in
		guard let bearer = req.headers.bearerAuthorization else {
			throw Abort(.unauthorized, reason: "Mising bearer token")
		}
		
		guard let session = try await UserSession.query(on: req.db)
			.filter(\UserSession.$token == bearer.token)
			.with(\.$user)
			.first()
		else {
			throw Abort(.unauthorized, reason: "Invalid session")
		}
		
		guard !session.isExpired else {
			try await session.delete(on: req.db)
			throw Abort(.unauthorized, reason: "Session expired")
		}
		
		let data = try req.content.decode(UpdateExperienceRequest.self)
		let user = session.user
		
		user.experience = data.experience
		user.level = (data.experience / 500) + 1
		
		try await user.save(on: req.db)
		
		return try meResponse(for: user)
	}
	
	auth.post("register") { req async throws -> AuthResponse in
		let data = try req.content.decode(RegisterRequest.self)
		let trimmedUsername = data.username.trimmingCharacters(in: .whitespacesAndNewlines)
		
		guard !trimmedUsername.isEmpty else {
			throw Abort(.badRequest, reason: "Username is required")
		}
		guard data.password.count >= 4 else {
			throw Abort(.badRequest, reason: "Password must be at least 4 characters long")
		}
		
		let existingUser = try await User.query(on: req.db)
			.filter(\User.$username == trimmedUsername)
			.first()
		if existingUser != nil {
			throw Abort(.badRequest, reason: "Username is already taken")
		}
		
		let hashedPassword = try Bcrypt.hash(data.password)
		let user = User(
			username: trimmedUsername,
			passwordHash: hashedPassword
		)
		
		try await user.save(on: req.db)
		let userID = try user.requireID()
		
		let token = [UInt8].random(count: 32).base64
		let expiresAt = Calendar.current.date(byAdding: .day, value: 7, to: Date())!
		
		let session = UserSession(
			token: token,
			userID: userID,
			expiresAt: expiresAt
		)
		
		try await session.save(on: req.db)
		
		return AuthResponse(
			userId: userID,
			username: user.username,
			sessionToken: token,
			expiresAt: expiresAt
		)
	}
	
	auth.post("login") { req async throws -> AuthResponse in
		let data = try req.content.decode(LoginRequest.self)
		
		guard let user = try await User.query(on: req.db)
			.filter(\User.$username == data.username)
			.first()
		else {
			throw Abort(.unauthorized, reason: "Invalid username or password")
		}
		
		guard try Bcrypt.verify(data.password, created: user.passwordHash) else {
			throw Abort(.unauthorized, reason: "Invalid username or password")
		}
		
		let userID = try user.requireID()
		let token = [UInt8].random(count: 32).base64
		let expiresAt = Calendar.current.date(byAdding: .day, value: 7, to: Date())!
		
		let session = UserSession(
			token: token,
			userID: userID,
			expiresAt: expiresAt
		)
		
		try await session.save(on: req.db)
		
		return AuthResponse(
			userId: userID,
			username: user.username,
			sessionToken: token,
			expiresAt: expiresAt
		)
	}
	
	auth.get("me") { req async throws -> MeResponse in
		guard let bearer = req.headers.bearerAuthorization else {
			throw Abort(.unauthorized, reason: "Missing bearer token")
		}
		
		guard let session = try await UserSession.query(on: req.db)
			.filter(\UserSession.$token == bearer.token)
			.with(\.$user)
			.first()
		else{
			throw Abort(.unauthorized, reason: "Invalid session")
		}
		
		guard !session.isExpired else {
			try await session.delete(on: req.db)
			throw Abort(.unauthorized, reason: "Session expired")
		}
		
		let user = session.user
		
		return try meResponse(for: user)
	}
	
	auth.post("logout") { req async throws -> HTTPStatus in
		guard let bearer = req.headers.bearerAuthorization else {
			throw Abort(.unauthorized, reason: "Missing bearer token")
		}
		
		if let session = try await UserSession.query(on: req.db)
			.filter(\UserSession.$token == bearer.token)
			.first() {
			try await session.delete(on: req.db)
		}
		
		return .ok
	}
}
