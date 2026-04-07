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
}

func routes(_ app: Application) throws {
	let auth = app.grouped("auth")
	
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
		
		return MeResponse(
			userId: try user.requireID(),
			username: user.username
		)
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
