import SwiftUI

struct UpgradeCard: Identifiable {
	let id: String
	let title: String
	let subtitle: String
	let icon: String
	let tint: Color
	let level: Int
	let maxLevel: Int
	let cost: Double?
}
