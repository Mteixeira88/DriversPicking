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
        self.manager?.delegate = self
        self.manager?.desiredAccuracy = .greatestFiniteMagnitude
    }
    
    // MARK: - Setup
    private func checkLocationPermissions() {
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
//                    self?.timerObs?.dispose()
                }
        }
    }
    
    private func generateDrivers(currentLocation: CLLocationCoordinate2D?) -> [DriverModel] {
        guard let currentLocation = currentLocation else {
            return []
        }
        
        var drivers = [DriverModel]()
        
        for n in 0...6 {
            print(n)
            let driverLocation = currentLocation.generateRandomCoordinate(random: n)
            let driver = DriverModel()
            driver.title = "driver \(n)"
            driver.coordinate = driverLocation
            drivers.append(driver)
        }
        
        return drivers
    }
    
    private func updateDriver() {
        guard let currentLocation = manager?.location?.coordinate else {
            return
        }
        privateDriver.enumerated().forEach { (index, driver) in
            driver.coordinate = currentLocation.generateRandomCoordinate(random: index)
        }
        drivers.onNext(privateDriver)
    }
}

extension MapViewModel: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationPermissions()
    }
}
