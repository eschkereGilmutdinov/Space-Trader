import Foundation

enum RatingType: String, CaseIterable, Identifiable {
	case level
	case balance
	
	var id: String { rawValue }
	
	var title: String {
		switch self {
		case .level:
			return "Уровень"
		case .balance:
			return "Деньги"
		}
	}
}
