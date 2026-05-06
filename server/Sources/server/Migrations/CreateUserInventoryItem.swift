import Fluent

struct CreateUserInventoryItem : AsyncMigration {
	func prepare(on database: any Database) async throws {
		try await database.schema(UserInventoryItem.schema)
			.id()
			.field("user_id", .uuid, .required, .references(User.schema, "id", onDelete: .cascade))
			.field("item_id", .string, .required)
			.field("name", .string, .required)
			.field("item_description", .string, .required)
			.field("price", .int, .required)
			.field("quantity", .int, .required)
			.unique(on: "user_id", "item_id")
			.create()
	}
	
	func revert(on database: any Database) async throws {
		try await database.schema(UserInventoryItem.schema).delete()
	}
}
