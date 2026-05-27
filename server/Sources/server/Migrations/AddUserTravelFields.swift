import Fluent

struct AddUserTravelFields: AsyncMigration {
	func prepare(on database: any Database) async throws {
		try await database.schema("users")
			.field("fuel", .int, .required, .sql(.default(100)))
			.field("current_station_id", .string, .required, .sql(.default("alpha-orbital")))
			.update()
	}
	
	func revert(on database: any Database) async throws {
		try await database.schema("users")
			.deleteField("fuel")
			.deleteField("current_station_id")
			.update()
	}
}
