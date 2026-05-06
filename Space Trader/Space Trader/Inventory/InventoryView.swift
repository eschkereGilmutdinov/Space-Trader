import SwiftUI

struct InventoryView: View {
	@EnvironmentObject private var session: SessionStore
	
	var body: some View {
		NavigationStack {
			ZStack {
				Color.black.ignoresSafeArea()
				ScrollView {
					VStack(alignment: .leading, spacing: 16) {
						InventoryHeaderView (
							totalItemsCount: totalItemsCount,
							balance: session.balance
						)
						
						if session.inventory.isEmpty {
							InventoryEmptyStateView()
						} else {
							InventoryListView(items: session.inventory)
						}
					}
					.padding(20)
				}
			}
			.navigationBarTitleDisplayMode(.inline)
		}
		.task {
			await session.refreshInventory()
		}
	}
	private var totalItemsCount: Int {
		session.inventory.reduce(0) { $0 + $1.quantity }
	}
}
