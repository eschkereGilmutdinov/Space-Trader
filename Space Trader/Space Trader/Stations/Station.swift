import Foundation

struct TradeItem: Identifiable, Hashable, Codable {
	let id: String
	let name: String
	let price: Int
	let description: String
	
	init (id: String, name: String, price: Int, description: String) {
		self.id = id
		self.name = name
		self.price = price
		self.description = description
	}
}


struct Station: Identifiable, Hashable {
    let id: String
    var name: String
    var type: String
    var imageName: String?
    var description: String
	var tradeItems: [TradeItem]

	init(id: String,
		 name: String,
		 type: String,
		 description: String,
		 imageName: String? = nil,
		 tradeItems: [TradeItem] = []
	) {
        self.id = id
        self.name = name
        self.type = type
        self.description = description
        self.imageName = imageName
		self.tradeItems = tradeItems
    }
}

struct StationRoute: Identifiable, Hashable {
	let from: String
	let to: String
	let fuelCost: Int
	
	var id: String { "\(from)-\(to)" }
}

let stationRoutes: [StationRoute] = [
	StationRoute(from: Constants.PlanetName.alphaOrbital, to: "beta-port", fuelCost: 18),
	StationRoute(from: Constants.PlanetName.alphaOrbital, to: "gamma-transit", fuelCost: 26),
	StationRoute(from: "beta-port", to: "gamma-transit", fuelCost: 14),
	StationRoute(from: "beta-port", to: "epsilon-outpost", fuelCost: 32),
	StationRoute(from: "gamma-transit", to: "delta-science", fuelCost: 22),
	StationRoute(from: "gamma-transit", to: "epsilon-outpost", fuelCost: 28),
	StationRoute(from: "delta-science", to: "epsilon-outpost", fuelCost: 20),
	StationRoute(from: "delta-science", to: Constants.PlanetName.alphaOrbital, fuelCost: 34)
]

let stationRouteCosts: [String: [String: Int]] = {
	var result: [String: [String: Int]] = [:]
	
	for route in stationRoutes {
		result[route.from, default: [:]][route.to] = route.fuelCost
		result[route.to, default: [:]][route.from] = route.fuelCost
	}
	
	return result
}()
