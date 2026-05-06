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
