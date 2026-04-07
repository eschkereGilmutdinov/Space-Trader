import Fluent
import Vapor

final class UserSession: Model, Content {
	static let schema = "user_sessions"
	
	@ID(key: .id)
	var id: UUID?
	
	@Parent(key: "user_id")
	var user: User
	
	@Field(key: "token")
	var token: String
	
	@Field(key: "expires_at")
	var expiresAt: Date
	
	@Timestamp(key: "created_at", on: .create)
	var createdAt: Date?
	
	init() {}
	
	init(id: UUID? = nil, token: String, userID: UUID, expiresAt: Date) {
		self.id = id
		self.token = token
		self.$user.id = userID
		self.expiresAt = expiresAt
	}
	
	var isExpired: Bool {
		expiresAt <= Date()
	}
}

extension UserSession: @unchecked Sendable {}
