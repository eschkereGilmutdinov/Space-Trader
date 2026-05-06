import SwiftUI

struct InventoryListView: View {
	let items: [InventoryItem]
	
	var body: some View {
		VStack(spacing: 12) {
			ForEach(items) { item in
				InventoryItemCardView(item: item)
			}
		}
	}
}
