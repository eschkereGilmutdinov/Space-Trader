import Foundation

struct AuthResponse: Decodable {
	let userId: UUID
	let username: String
	let sessionToken: String
	let expiresAt: Date
}

struct MeResponse: Decodable {
	let userId: UUID
	let username: String
	let level: Int
	let experience: Int
	let balance: Double
}

struct RegisterRequest: Encodable {
	let username: String
	let password: String
}

struct LoginRequest: Encodable {
	let username: String
	let password: String
}

struct UpdateExperienceRequest: Encodable {
	let experience: Int
}

struct InventoryItem: Identifiable, Codable, Hashable {
	let itemId: String
	let name: String
	let description: String
	let price: Int
	let quantity: Int
	
	var id: String { itemId }
	
	var tradeItem: TradeItem {
		TradeItem(
			id: itemId,
			name: name,
			price: price,
			description: description
		)
	}
}

struct InventoryResponse: Decodable {
	let items: [InventoryItem]
}

struct TradeResponse: Decodable {
	let user: MeResponse
	let inventory: InventoryResponse
}

struct TradeRequest: Encodable {
	let stationId: String
	let itemId: String
}

struct UserUpgradesResponse: Decodable {
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

struct UpgradePurchaseResponse: Decodable {
	let user: MeResponse
	let upgrades: UserUpgradesResponse
}

struct UpgradeRequest: Encodable {
	let type: String
}

private struct EmptyResponse: Decodable {}

final class APIClient {
	static let shared = APIClient()

	private let baseURL = URL(string: "http://127.0.0.1:8080")!
	
	private let decoder: JSONDecoder = {
		let decoder = JSONDecoder()
		decoder.dateDecodingStrategy = .iso8601
		return decoder
	}()
	
	private let encoder: JSONEncoder = {
		let encoder = JSONEncoder()
		encoder.dateEncodingStrategy = .iso8601
		return encoder
	}()
	
	func upgrades(token: String) async throws -> UserUpgradesResponse {
		try await send(
			path: "/auth/upgrades",
			method: "GET",
			body: Optional<String>.none,
			token: token,
			responseType: UserUpgradesResponse.self
		)
	}
	
	func buyUpgrades(token: String, type: String) async throws -> UpgradePurchaseResponse {
		try await send(
			path: "/auth/upgrades/buy",
			method: "POST",
			body: UpgradeRequest(type: type),
			token: token,
			responseType: UpgradePurchaseResponse.self
		)
	}
	
	func inventory(token: String) async throws -> InventoryResponse {
		try await send(
			path: "/auth/inventory",
			method: "GET",
			body: Optional<String>.none,
			token: token,
			responseType: InventoryResponse.self
		)
	}
	
	func buy(token: String, stationId: String, itemId: String) async throws -> TradeResponse {
		try await send(
			path: "/auth/trade/buy",
			method: "POST",
			body: TradeRequest(stationId: stationId, itemId: itemId),
			token: token,
			responseType: TradeResponse.self
		)
	}
	
	func sell(token: String, stationId: String, itemId: String) async throws -> TradeResponse {
		try await send(
			path: "auth/trade/sell",
			method: "POST",
			body: TradeRequest(stationId: stationId, itemId: itemId),
			token: token,
			responseType: TradeResponse.self
		)
	}
	
	func register(username: String, password: String) async throws -> AuthResponse {
		try await send(
			path: "/auth/register",
			method: "POST",
			body: RegisterRequest(username: username, password: password),
			token: nil,
			responseType: AuthResponse.self
		)
	}
	
	func login(username: String, password: String) async throws -> AuthResponse {
		try await send(
			path: "/auth/login",
			method: "POST",
			body: LoginRequest(username: username, password: password),
			token: nil,
			responseType: AuthResponse.self
		)
	}
	
	func me(token: String) async throws -> MeResponse {
		try await send(
			path: "/auth/me",
			method: "GET",
			body: Optional<String>.none,
			token: token,
			responseType: MeResponse.self
		)
	}
	
	func logout(token: String) async throws {
		_ = try await send(
			path: "/auth/logout",
			method: "POST",
			body: Optional<String>.none,
			token: token,
			responseType: EmptyResponse.self
		)
	}
	
	func updateExperience(token: String, experience: Int) async throws -> MeResponse {
		try await send(
			path: "auth/experience",
			method: "POST",
			body: UpdateExperienceRequest(experience: experience),
			token: token,
			responseType: MeResponse.self)
	}
	
	private func send<T: Decodable, Body: Encodable>(path: String, method: String, body: Body?, token: String?, responseType: T.Type) async throws -> T {
			let url = baseURL.appendingPathComponent(path.trimmingCharacters(in: CharacterSet(charactersIn: "/")))
			var request = URLRequest(url: url)
			request.httpMethod = method
			request.setValue("application/json", forHTTPHeaderField: "Content-Type")

			if let token {
				request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
			}

			if let body {
				request.httpBody = try encoder.encode(body)
			}

			let (data, response) = try await URLSession.shared.data(for: request)

			guard let http = response as? HTTPURLResponse else {
				throw URLError(.badServerResponse)
			}

			guard (200...299).contains(http.statusCode) else {
				let text = String(data: data, encoding: .utf8) ?? "Unknown server error"
				throw NSError(domain: "APIError", code: http.statusCode, userInfo: [
					NSLocalizedDescriptionKey: text
				])
			}

			if T.self == EmptyResponse.self {
				return EmptyResponse() as! T
			}

			return try decoder.decode(T.self, from: data)
		}
}
