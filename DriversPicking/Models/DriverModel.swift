import Foundation

struct DriverModel: Codable {
    // MARK: - Properties
    var id: String = UUID().uuidString
    var name: String = "User"
    var image: String? = nil
}
