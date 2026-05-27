import SwiftUI

struct StationDetailView: View {
	@EnvironmentObject private var session: SessionStore
	@Environment(\.dismiss) private var dismiss
	
	@State private var isTraveling = false
	@State private var travelDestinationName: String?
	@State private var showFuelShop = false
	@State private var travelErrorMessage: String?
	
    private let backgroundImageName = "Background"
    let station: Station
	
	private var isCurrentStation: Bool {
		session.currentStationID == station.id
	}
    
    var body: some View {
        ZStack {
            Image(backgroundImageName)
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
			Color.black.opacity(0.7).ignoresSafeArea()
			
            ScrollView {
                VStack(spacing: 16) {
                    Image(station.imageName ?? "globe")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    
                    Text(station.name)
                        .font(.custom("Montserrat-Regular", size: 30))
                        .foregroundStyle(Color(.white))
						.bold()
                    Text(station.description)
                        .font(.custom("Montserrat-Regular", size: 20))
                        .foregroundStyle(Color(.white))
                        .multilineTextAlignment(.leading)
					
					RouteFuelInfoView(station: station)

					if let travelErrorMessage {
						Text(travelErrorMessage)
							.font(.custom("Montserrat-Regular", size: 15))
							.foregroundStyle(.red)
					}
					
					VStack (alignment: .leading, spacing: 10) {
						Text("Товары станции")
							.font(.custom("Montserrat-Bold", size: 22))
							.foregroundStyle(.white)
						ForEach(station.tradeItems) { item in
							VStack(alignment: .leading, spacing: 4) {
								HStack {
									Text(item.name)
										.foregroundStyle(.white)
										.font(.custom("Montserrat-Regular", size: 18))
									Spacer()
									Text("\(item.price)$")
										.font(.custom("Montserrat-Regular", size: 18))
										.foregroundStyle(.white)
								}
								Text(item.description)
									.font(.custom("Montserrat-Regular", size: 15))
									.foregroundStyle(.white.opacity(0.75))
							}
							.padding()
							.frame(maxWidth: .infinity, alignment: .leading)
							.background(Color.white.opacity(0.12))
							.clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
						}
					}
					.frame(maxWidth: .infinity, alignment: .leading)
					
					Button {
						travel(to: station)
					} label: {
						Text(travelButtonTitle)
							.font(.custom("Montserrat-Regular", size: 18))
							.frame(maxWidth: .infinity)
							.padding(.vertical, 14)
							.background(
								session.currentStationID == station.id
								? Color.gray.opacity(0.4)
								: Color.white
							)
							.foregroundStyle(.black)
							.clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
					}
					.disabled(session.currentStationID == station.id)
                }
                .padding()
            }
        }
		.sheet(isPresented: $showFuelShop) {
			FuelPurchaseView()
		}
		.overlay {
			if isTraveling {
				TravelLoadingView(destinationName: travelDestinationName)
					.transition(.opacity.combined(with: .scale(scale: 0.96)))
			}
		}
		.animation(.easeInOut(duration: 0.25), value: isTraveling)
    }
	
	private var travelButtonTitle: String {
		if session.currentStationID == station.id {
			return "Вы уже на этой станции"
		}
		
		guard let cost = session.effectiveFuelCost(to: station) else {
			return "Маршрут недоступен"
		}
		
		return "Переместиться - \(cost) топлива"
	}
	
	private func travel(to station: Station) {
		guard !isTraveling else { return }
		guard session.currentStationID != station.id else { return }
		guard session.effectiveFuelCost(to: station) != nil else { return }
		
		guard session.canTravel(to: station) else {
			showFuelShop = true
			return
		}
		
		travelErrorMessage = nil
		travelDestinationName = station.name
		isTraveling = true
		
		Task { @MainActor in
			do {
				try? await Task.sleep(nanoseconds: 1_300_000_000)
				_ = try await session.travel(to: station)
				
				withAnimation(.easeInOut(duration: 0.25)) {
					isTraveling = false
				}
				
				travelDestinationName = nil
				dismiss()
			} catch {
				travelErrorMessage = error.localizedDescription

				if !session.canTravel(to: station) {
					showFuelShop = true
				}
				
				withAnimation(.easeInOut(duration: 0.25)) {
					isTraveling = false
				}

				travelDestinationName = nil
			}
		}
	}
}
