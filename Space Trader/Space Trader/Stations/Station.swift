import Foundation

class Station: Identifiable {
    let id: UUID
    var name: String
    var type: String
    var imageName: String?
    var description: String

    init(id: UUID = UUID(), name: String, type: String, description: String, imageName: String? = nil) {
        self.id = id
        self.name = name
        self.type = type
        self.description = description
        self.imageName = imageName
    }
}
