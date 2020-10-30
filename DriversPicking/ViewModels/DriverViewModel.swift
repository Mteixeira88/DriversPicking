import MapKit
import RxSwift
import Contacts

struct DriverViewModel {
    // MARK: - Error enum
    enum DriverViewModelError {
        case noAddress(String)
    }
    
    // MARK: - Properties
    private var driver: DriverModel

    private var driverService: FoundDriverService
    
    var annotation: DriverAnnotation
    
    var displayName: String {
        return driver.name
    }
    
    let error = PublishSubject<DriverViewModelError>()
    
    // MARK: - Init
    init(
        driver: DriverModel,
        annotation: DriverAnnotation,
        driverService: FoundDriverService = FoundDriverService()
    ) {
        self.driver = driver
        self.annotation = annotation
        self.driverService = driverService
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
                    self.error.onNext(.noAddress("No address found"))
                    return
                }
                
                let address = postalAddressFormatter.string(from: postalAddress)
                observer.onNext(address)
            }
            
            return Disposables.create()
        }
    }
    
    
    func downloadImage() -> Observable<UIImage> {
        return driverService.downloadImage(from: driver.image)
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
