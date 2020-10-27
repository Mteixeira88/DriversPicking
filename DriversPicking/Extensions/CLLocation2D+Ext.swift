import CoreLocation
import UIKit

extension CLLocationCoordinate2D {
    func generateRandomCoordinate(random: Int) -> CLLocationCoordinate2D {
        let meterCord = 0.00900900900901 / 1000
        
        let randomMeters = Int.random(in: 100...300)
        
        let metersCordN = meterCord * Double(randomMeters)
        
        switch random {
        case 0:
            return CLLocationCoordinate2D(latitude: latitude + metersCordN, longitude: longitude + metersCordN)
        case 1:
            return CLLocationCoordinate2D(latitude: latitude - metersCordN, longitude: longitude - metersCordN)
        case 2:
            return CLLocationCoordinate2D(latitude: latitude + metersCordN, longitude: longitude - metersCordN)
        case 3:
            return CLLocationCoordinate2D(latitude: latitude, longitude: longitude + metersCordN)
        case 4:
            return CLLocationCoordinate2D(latitude: latitude, longitude: longitude - metersCordN)
        default:
            return CLLocationCoordinate2D(latitude: latitude - metersCordN, longitude: longitude)
        }
    }
}
