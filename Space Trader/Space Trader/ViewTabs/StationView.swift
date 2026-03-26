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
										TextRow(station: station)
                                        Spacer()
										ImageRow(station: station)
											.matchedTransitionSource(id: station.id, in: ns)
                                    } else {
										ImageRow(station: station)
                                            .matchedTransitionSource(id: station.id, in: ns)
                                        Spacer()
										TextRow(station: station)
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
