import UIKit

enum PinIdent: String {
    case user = "user"
    case driver = "driver"
    case driverSelected = "driver-selected"
}

enum Images: String {
    case locationPin = "location-pin"
    case sportCarSelected = "sport-car-selected"
    case sportCar = "sport-car"
}

enum Assets {
    static func image(_ assetImage: Images) -> UIImage {
        guard let image = UIImage(named: assetImage.rawValue) else {
            fatalError("Could not initialize Image UIImage named \"\(assetImage.rawValue)\".")
        }
        return image
    }
}
