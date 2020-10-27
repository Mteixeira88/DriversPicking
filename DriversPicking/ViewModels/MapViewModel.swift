import UIKit
import CoreLocation
import RxSwift
import RxCocoa
import MapKit

protocol MapViewModelProtocol {
    func currentLocationAt(_ currentLocation: CLLocationCoordinate2D?)
}

class MapViewModel: NSObject {
    
    // MARK: - Properties
    private(set) var locationDelegate: MapViewModelProtocol?
    private(set) var manager: CLLocationManager?
    private(set) var delegate: CLLocationManagerDelegate?
    private let disposeBag = DisposeBag()
    private var timerObs: Disposable?
    
    
    var drivers = BehaviorSubject(value: [DriverModel]())
    
    private var privateDriver = [DriverModel]()
    
    // MARK: - Init
    init(locationDelegate: MapViewModelProtocol, manager: CLLocationManager = CLLocationManager()) {
        super.init()
        self.locationDelegate = locationDelegate
        self.manager = manager
        checkLocationPermissions()
    }
    
    // MARK: - Setup
    private func checkLocationPermissions() {
        manager?.delegate = self
        manager?.desiredAccuracy = .greatestFiniteMagnitude
        
        switch manager?.authorizationStatus {
        case .restricted, .denied, .notDetermined:
            manager?.requestWhenInUseAuthorization()
        default:
            locationDelegate?.currentLocationAt(manager?.location?.coordinate)
            privateDriver = generateDrivers(currentLocation: manager?.location?.coordinate)
            drivers.onNext(privateDriver)
            manager?.startUpdatingLocation()
            timerObs = Observable<Int>
                .interval(RxTimeInterval.seconds(5), scheduler: MainScheduler.instance)
                .subscribe { [weak self ]_ in
                    self?.updateDriver()
                    self?.timerObs?.dispose()
                }
        }
    }
    
    private func generateDrivers(currentLocation: CLLocationCoordinate2D?) -> [DriverModel] {
        guard let currentLocation = currentLocation else {
            return []
        }
        
        var drivers = [DriverModel]()
        
        for n in 0...5 {
            let driverLocation = currentLocation.generateRandomCoordinate(random: n)
            let driver = DriverModel()
            driver.coordinate = driverLocation
            drivers.append(driver)
        }
        
        return drivers
    }
    
    private func updateDriver() {
        var newDrivers = [DriverModel]()
        privateDriver.enumerated().forEach { (index, driver) in
            driver.coordinate = driver.coordinate.generateRandomCoordinate(random: 3)
            newDrivers.append(driver)
        }
        privateDriver = newDrivers
        drivers.onNext(privateDriver)
    }
}

extension MapViewModel: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationPermissions()
    }
}
