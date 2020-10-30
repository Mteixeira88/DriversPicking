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
    case testImage = "test-image"
}

enum Assets {
    static func image(_ assetImage: Images) -> UIImage {
        guard let image = UIImage(named: assetImage.rawValue) else {
            fatalError("Could not initialize Image UIImage named \"\(assetImage.rawValue)\".")
        }
        return image
    }
}


class Utils {
    static func getServerUrl() -> URL {
        if let path = Bundle.main.path(forResource: "Info", ofType: "plist") {
            guard let nsDictionay = NSDictionary(contentsOfFile: path),
                let serverString = nsDictionay["SERVER_URL"] as? String,
                let url = URL(string: serverString) else {
                fatalError("No URL to proceed")
            }
            return url
        }

        fatalError("No URL to proceed")
    }
}
