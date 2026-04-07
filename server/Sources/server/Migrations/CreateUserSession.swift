import Fluent

struct CreateUserSession: AsyncMigration {
	func prepare(on database: any Database) async throws {
		try await database.schema(UserSession.schema)
			.id()
			.field("token", .string, .required)
			.field("user_id", .uuid, .required, .references(User.schema, .id, onDelete: .cascade))
			.field("expires_at", .datetime, .required)
			.field("created_at", .datetime)
			.unique(on: "token")
			.create()
	}
	
	func revert(on database: any Database) async throws {
		try await database.schema(UserSession.schema).delete()
	}
}
