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
    
    
    var drivers = BehaviorSubject(value: [DriverViewModel]())
    
    private let driverService: DriverServiceProtocol
    
    private var privateDriver = [DriverViewModel]()
    
    // MARK: - Init
    init(
        locationDelegate: MapViewModelProtocol,
        manager: CLLocationManager = CLLocationManager(),
        driverService: DriverServiceProtocol = DriverService()
    ) {
        self.driverService = driverService
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
            manager?.startUpdatingLocation()
            generateDrivers(currentLocation: manager?.location?.coordinate)
        }
    }
    
    private func generateDrivers(currentLocation: CLLocationCoordinate2D?) {
        guard let currentLocation = currentLocation else {
            return
        }
        
        driverService.fetchDrivers()
            .map {
                $0.map { driver -> DriverViewModel in
                    let annotation = Annotation()
                    annotation.coordinate = currentLocation.generateRandomCoordinate()
                    return DriverViewModel(
                        driver: driver,
                        annotation: annotation
                    )
                }
            }
            .subscribe(onNext: { [weak self] drivers in
                guard let self = self else {
                    return
                }
                
                self.privateDriver = drivers
                self.drivers.onNext(drivers)
                
                Observable<Int>
                    .interval(RxTimeInterval.seconds(5), scheduler: MainScheduler.instance)
                    .subscribe { [weak self ]_ in
                        self?.updateDriver()
                    }
                    .disposed(by: self.disposeBag)
            })
            .disposed(by: disposeBag)
    }
    
    private func updateDriver() {
        guard let currentLocation = manager?.location?.coordinate else {
            return
        }
        privateDriver.enumerated().forEach { (index, driver) in
            driver.annotation.coordinate = currentLocation.generateRandomCoordinate()
        }
        drivers.onNext(privateDriver)
    }
}

extension MapViewModel: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationPermissions()
    }
}
