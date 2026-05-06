import Fluent
import Vapor

final class UserInventoryItem : Model, Content {
	static let schema = "user_inventory_items"
	
	@ID(key: .id)
	var id: UUID?
	
	@Parent(key: "user_id")
	var user: User
	
	@Field(key: "item_id")
	var itemID: String
	
	@Field(key: "name")
	var name: String
	
	@Field(key: "item_description")
	var itemDescription: String
	
	@Field(key: "price")
	var price: Int
	
	@Field(key: "quantity")
	var quantity: Int
	
	init() {}
	
	init(
		id: UUID? = nil,
		userID: UUID,
		itemID: String,
		name: String,
		itemDescription: String,
		price: Int,
		quantity: Int
	) {
		self.id = id
		self.$user.id = userID
		self.itemID = itemID
		self.name = name
		self.itemDescription = itemDescription
		self.price = price
		self.quantity = quantity
	}
}

extension UserInventoryItem: @unchecked Sendable {}
