import SwiftUI

struct StationView: View {
	@EnvironmentObject private var session: SessionStore
	
    @Namespace private var ns
    private let backgroundImageName = "Background"
	
	@State private var isTraveling = false
	@State private var travelDestinationName: String?
	@State private var showFuelShop = false

	var body: some View {
		NavigationStack {
			ZStack {
				Color.black.ignoresSafeArea()
				
				Image(backgroundImageName)
					.resizable()
					.scaledToFill()
					.ignoresSafeArea()
				
				ScrollView(.vertical, showsIndicators: false) {
					LazyVStack(spacing: 20) {
						FuelHeaderView(showFuelShop: $showFuelShop)
							.padding(.horizontal, 8)
						ForEach(Array(stations.enumerated()), id: \.element.id) { index, station in
							NavigationLink {
								StationDetailView(station: station)
									.navigationTransition(.zoom(sourceID: station.id, in: ns))
							} label: {
								StationCardView(
									station: station,
									index: index,
									isCurrentStation: session.currentStationID == station.id,
									namespace: ns
								)
							}
							.buttonStyle(.plain)
						}
					}
					.padding(.horizontal, 20)
					.padding(.vertical, 16)
				}
			}
		}
		.sheet(isPresented: $showFuelShop) {
			FuelPurchaseView()
		}
		.alert(item: $session.pendingTravelEvent) { event in
			Alert(
				title: Text("Событие: \(event.title)"),
				message: Text(travelEventAlertMessage(for: event)),
				dismissButton: .default(Text("OK")) {
					session.pendingTravelEvent = nil
				}
			)
		}
    }
	
	private func travelEventAlertMessage(for event: TravelEventResponse) -> String {
		if event.avoided {
			return "\(event.description)\n\n"
		}
		
		let penalty = event.penaltyDescription ?? "Получен штраф"
		return "\(event.description)\n\n\(penalty)"
	}
}
