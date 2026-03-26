import SwiftUI

struct StationDetailView: View {
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
                }
                .padding()
            }
        }
    }
}
