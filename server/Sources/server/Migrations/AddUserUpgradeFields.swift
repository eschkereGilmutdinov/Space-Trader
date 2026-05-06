import Fluent

struct AddUserUpgradeFields: AsyncMigration {
	func prepare(on database: any Database) async throws {
		try await database.schema(User.schema)
			.field("speed_upgrade_level", .int, .required, .sql(.default(0)))
			.field("profit_upgrade_level", .int, .required, .sql(.default(0)))
			.field("fuel_efficiency_upgrade_level", .int, .required, .sql(.default(0)))
			.field("durability_upgrade_level", .int, .required, .sql(.default(0)))
			.update()
	}
	
	func revert(on database: any Database) async throws {
		try await database.schema(User.schema)
			.deleteField("speed_upgrade_level")
			.deleteField("profit_upgrade_level")
			.deleteField("fuel_efficiency_upgrade_level")
			.deleteField("durability_upgrade_level")
			.update()
	}
}
