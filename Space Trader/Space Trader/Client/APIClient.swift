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
}

struct RegisterRequest: Encodable {
	let username: String
	let password: String
}

struct LoginRequest: Encodable {
	let username: String
	let password: String
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
