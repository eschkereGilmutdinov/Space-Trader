import Vapor
import Fluent
import FluentPostgresDriver

public func configure(_ app: Application) async throws {
	let hostname = Environment.get("DB_HOST") ?? "127.0.0.1"
	let port = Environment.get("DB_PORT").flatMap(Int.init) ?? 5432
	let username = Environment.get("DB_USER") ?? "postgres"
	let password = Environment.get("DB_PASSWORD") ?? "1234"
	let database = Environment.get("DB_NAME") ?? "spacetrader"
	
	app.databases.use(
		.postgres(
			hostname: hostname,
			port: port,
			username: username,
			password: password,
			database: database
		),
		as: .psql
	)
	
	app.migrations.add(CreateUser())
	app.migrations.add(CreateUserSession())
	app.migrations.add(AddUserStatsField())
	app.migrations.add(CreateUserInventoryItem())
	app.migrations.add(AddUserUpgradeFields())
	app.migrations.add(AddUserTravelFields())
    try routes(app)
}
