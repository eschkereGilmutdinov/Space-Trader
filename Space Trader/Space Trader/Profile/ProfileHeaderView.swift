import SwiftUI
import PhotosUI

struct ProfileHeaderView: View {
	let username: String?
	let userId: String?
	
	@EnvironmentObject var sessionStore: SessionStore
	@State private var selectedItem: PhotosPickerItem?
	
	var body: some View {
		VStack(spacing: 14) {
			PhotosPicker(selection: $selectedItem, matching: .images) {
				ZStack {
					if let avatar = sessionStore.avatarImage {
						Image(uiImage: avatar)
							.resizable()
							.scaledToFill()
							.frame(width: 120, height: 120)
							.clipShape(Circle())
					} else {
						Circle()
							.fill (
								LinearGradient (
									colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.8)],
									startPoint: .topLeading,
									endPoint: .bottomTrailing
								)
							)
							.frame(width: 120, height: 120)
						Image(systemName: "person.crop.circle.fill")
							.resizable()
							.scaledToFit()
							.frame(width: 90, height: 90)
							.foregroundStyle(.white)
					}
				}
				.overlay(alignment: .bottomTrailing) {
					Image(systemName: "camera.fill")
						.foregroundStyle(.white)
						.padding(8)
						.background(Color.black.opacity(0.7))
						.clipShape(Circle())
				}
				.shadow(radius: 10)
			}
			.buttonStyle(.plain)
			.onChange(of: selectedItem) { _, newItem in
				Task {
					await loadSelectedPhoto(from: newItem)
				}
			}
			if sessionStore.avatarImage != nil {
				Button("Удалить фото") {
					sessionStore.removeAvatar()
				}
				.font(.custom("Montserrat-Regular", size: 13))
				.foregroundColor(.white.opacity(0.85))
			}
			
			Text(username ?? "Unknown")
				.font(.custom("Montserrat-Regular", size: 30))
				.foregroundStyle(.white)
			
			Text("ID: \(userId ?? "-")")
				.font(.custom("Montserrat-Regular", size: 13))
				.foregroundStyle(.white.opacity(0.8))
				.multilineTextAlignment(.center)
				.textSelection(.enabled)
		}
		.padding(24)
		.frame(maxWidth: .infinity)
		.background(.ultraThinMaterial)
		.cornerRadius(24)
	}
	
	private func loadSelectedPhoto(from item: PhotosPickerItem?) async {
		guard let item else { return }
		do {
			if let data = try await item.loadTransferable(type: Data.self),
			   let image = UIImage(data: data) {
				try sessionStore.saveAvatar(image)
			}
		} catch {
			print("Failed to load avatar", error)
		}
	}
}
