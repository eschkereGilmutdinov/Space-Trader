import SwiftUI

struct StationDetailView: View {
	@EnvironmentObject private var session: SessionStore
	@State private var isTraveling = false
	@State private var travelDestinationName: String?
	
    private let backgroundImageName = "Background"
    let station: Station
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            Image(backgroundImageName)
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
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
						Text(session.currentStationID == station.id ? "Вы уже на этой станции" : "Переместиться")
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
		.overlay {
			if isTraveling {
				TravelLoadingView(destinationName: travelDestinationName)
					.transition(.opacity.combined(with: .scale(scale: 0.96)))
			}
		}
		.animation(.easeInOut(duration: 0.25), value: isTraveling)
    }
	
	private func travel(to station: Station) {
		guard !isTraveling else { return }
		
		travelDestinationName = station.name
		isTraveling = true
		
		Task { @MainActor in
			try? await Task.sleep(nanoseconds: 1_300_000_000)
			session.moveToStation(station)
			withAnimation(.easeInOut(duration: 0.25)) {
				isTraveling = false
			}
			travelDestinationName = nil
		}
	}
}
