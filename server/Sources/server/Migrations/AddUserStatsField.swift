import Fluent

struct AddUserStatsField: AsyncMigration {
	func prepare(on database: any Database) async throws {
		try await database.schema(User.schema)
			.field("level", .int, .required, .sql(.default(1)))
			.field("experience", .int, .required, .sql(.default(0)))
			.field("balance", .double, .required, .sql(.default(1000)))
			.update()
	}
	
	func revert(on database: any Database) async throws {
		try await database.schema(User.schema)
			.deleteField("level")
			.deleteField("experience")
			.deleteField("balance")
			.update()
	}
}
