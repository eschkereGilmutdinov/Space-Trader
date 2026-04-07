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
	
	init() {}
	
	init(id: UUID? = nil, username: String, passwordHash: String) {
		self.id = id
		self.username = username
		self.passwordHash = passwordHash
	}
}

extension User: @unchecked Sendable {}
