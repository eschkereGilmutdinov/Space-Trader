import SwiftUI

struct StationView: View {
    @Namespace private var ns
    private let backgroundImageName = "Background"

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
                        ForEach(Array(stations.enumerated()), id: \.element.id) { index, station in
                            NavigationLink {
                                StationDetailView(station: station)
                                    .navigationTransition(.zoom(sourceID: station.id, in: ns))
                            } label: {
                                HStack {
                                    if index % 2 == 0 {
                                        Text(station.name)
                                            .font(.custom("Montserrat-Regular", size: 20))
                                            .foregroundStyle(
                                                LinearGradient(
                                                    stops: [
                                                        .init(color: .white, location: 0.0),
                                                        .init(color: Color(red: 0.953, green: 0.969, blue: 1.0), location: 0.45),
                                                        .init(color: Color(red: 0.812, green: 0.902, blue: 1.0), location: 1.0)
                                                    ],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                            .tracking(0.4)
											.bold()

                                        Spacer()

                                        Image(station.imageName ?? "globe")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 110, height: 110)
                                            .clipShape(RoundedRectangle(cornerRadius: 12))
                                            .matchedTransitionSource(id: station.id, in: ns)
                                    } else {
                                        Image(station.imageName ?? "globe")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 110, height: 110)
                                            .clipShape(RoundedRectangle(cornerRadius: 12))
                                            .matchedTransitionSource(id: station.id, in: ns)

                                        Spacer()

                                        Text(station.name)
                                            .font(.custom("Montserrat-Regular", size: 20))
                                            .foregroundStyle(
                                                LinearGradient(
                                                    stops: [
                                                        .init(color: .white, location: 0.0),
                                                        .init(color: Color(red: 0.953, green: 0.969, blue: 1.0), location: 0.45),
                                                        .init(color: Color(red: 0.812, green: 0.902, blue: 1.0), location: 1.0)
                                                    ],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
											.tracking(0.4)
											.bold()
                                    }
                                }
                                .padding(.horizontal, 28)
                                .padding(.vertical, 12)
                                .frame(maxWidth: .infinity, minHeight: 180)
                                .background(
                                    RoundedRectangle(cornerRadius: 34, style: .continuous)
                                        .fill(Color.white.opacity(0.16))
                                )
                                .contentShape(RoundedRectangle(cornerRadius: 34, style: .continuous))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                }
            }
        }
    }
}
