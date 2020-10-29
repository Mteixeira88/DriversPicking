import MapKit
import RxSwift
import Contacts

struct DriverViewModel {
    // MARK: - Properties
    static let imageCache = NSCache<AnyObject, AnyObject>()
    static var address: String? = nil
    
    private var driver: DriverModel
    
    var annotation: DriverAnnotation
    
    var displayName: String {
        return driver.name
    }
    
    // MARK: - Init
    init(
        driver: DriverModel,
        annotation: DriverAnnotation
    ) {
        self.driver = driver
        self.annotation = annotation
    }
    
    // MARK: - Setup
    func getAddress(with coordinates: CLLocationCoordinate2D) -> Observable<String> {
        return Observable.create { (observer) -> Disposable in
            CLGeocoder().reverseGeocodeLocation(
                CLLocation(
                    latitude: coordinates.latitude,
                    longitude: coordinates.longitude
                )) { (clPlacemark, error) in
                guard let place = clPlacemark?.first else {
                    observer.onNext("Address unknown")
                    return
                }
                
                let postalAddressFormatter = CNPostalAddressFormatter()
                postalAddressFormatter.style = .mailingAddress
                guard let postalAddress = place.postalAddress else {
                    return
                }
                
                let address = postalAddressFormatter.string(from: postalAddress)
                observer.onNext(address)
            }
            
            return Disposables.create {}
        }
    }
    
    
    func downloadImage() -> Observable<UIImage> {
        return Observable.create { (observer) -> Disposable in
            
            
            
            guard let imageString = driver.image,
                let url = URL(string: imageString) else {
                observer.onNext(Assets.image(.locationPin))
                return Disposables.create {
                }
            }
            
            if let imageFromCache = DriverViewModel.imageCache.object(forKey: imageString as AnyObject),
               let image = imageFromCache as? UIImage {
                observer.onNext(image)
                return Disposables.create {}
            }
            
            URLSession.shared.dataTask(with: url, completionHandler: { (data, _, error) -> Void in
                if error != nil {
                    observer.onNext(Assets.image(.locationPin))
                    return
                }
                if let data = data {
                    guard let imageToCache = UIImage(data: data) else { return }
                    DriverViewModel.imageCache.setObject(imageToCache, forKey: driver.image as AnyObject)
                    observer.onNext(imageToCache)
                }
            }).resume()
            
            return Disposables.create {
            }
        }
    }
    
    func getDirections(
        from source: CLLocationCoordinate2D,
        to destination: CLLocationCoordinate2D
    ) -> Observable<String> {
        return Observable.create { (observer) -> Disposable in
            
            let request = MKDirections.Request()
            request.source = MKMapItem(placemark: MKPlacemark(coordinate: source))
            request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destination))
            request.requestsAlternateRoutes = false
            request.transportType = .automobile
            
            let directions = MKDirections(request: request)
            directions.calculate { (response, error) in
                response?.routes.forEach({ (route) in
                    let time = route.expectedTravelTime / 60
                    var string = Date().convertToFormat()
                    if !time.isZero {
                        string = "\(route.distance)mts and \(Int(time))min away"
                    }
                    observer.onNext(string)
                })
            }
            
            return Disposables.create{}
        }
    }
}
