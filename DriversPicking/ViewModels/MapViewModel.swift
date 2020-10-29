import UIKit
import CoreLocation
import RxSwift
import RxCocoa
import MapKit
import Contacts

protocol MapViewModelProtocol {
    func currentLocationAt(_ currentLocation: CLLocationCoordinate2D?)
}

class MapViewModel: NSObject {
    
    // MARK: - Properties
    private(set) var locationDelegate: MapViewModelProtocol?
    private(set) var manager: CLLocationManager?
    private(set) weak var delegate: CLLocationManagerDelegate?
    private let disposeBag = DisposeBag()
    private var timerObs: Disposable?
    private let driverService: DriverServiceProtocol
    private(set) var userDriver = DriverViewModel(driver: DriverModel(), annotation: DriverAnnotation())
    
    // MARK: - Subjects
    var drivers = BehaviorSubject(value: [DriverViewModel]())
    var presentedDriver: BehaviorSubject<DriverViewModel?> = BehaviorSubject(value: nil)

    
    // MARK: - Init
    init(
        manager: CLLocationManager = CLLocationManager(),
        driverService: DriverServiceProtocol = DriverService()
    ) {
        self.driverService = driverService
        super.init()
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
        
        userDriver.annotation.coordinate = currentLocation
        presentedDriver.onNext(userDriver)
        
        driverService.fetchDrivers()
            .map {
                $0.map { driver -> DriverViewModel in
                    let annotation = DriverAnnotation()
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
                self.startDrivers(with: drivers)
            }, onError: { [weak self ] error in
                self?.drivers.onError(error)
            })
            .disposed(by: disposeBag)
    }
    
    private func startDrivers(with drivers: [DriverViewModel]? = nil) {
        timerObs?.dispose()
        timerObs = Observable<Int>
            .interval(RxTimeInterval.seconds(5), scheduler: MainScheduler.instance)
            .subscribe { [weak self ] _ in
                self?.updateDriver()
            }
        if let drivers = drivers {
            self.drivers.onNext(drivers)
        } else {
            updateDriver()
        }
    }
    
    private func updateDriver() {
        guard let currentLocation = manager?.location?.coordinate else {
            return
        }
        do {
            try self.drivers
                .value()
                .enumerated()
                .forEach { (index, driver) in
                    driver.annotation.coordinate = currentLocation.generateRandomCoordinate()
                    if let pickedDriver = try? presentedDriver.value(),
                       driver.annotation.id == pickedDriver.annotation.id {
                        self.presentedDriver.onNext(driver)
                    }
            }
        } catch {
            self.drivers.onError(error)
        }
    }
    
    func pickDriver(with annotation: DriverAnnotation?) {
        guard let annotation = annotation else {
            presentedDriver.onNext(userDriver)
            return
        }
        do {
            let driver = try drivers.value().first(
                where: { $0.annotation.id == annotation.id }
            )
            presentedDriver.onNext(driver)
        } catch {
            drivers.onError(error)
        }
        
    }
    
    func setDelegate(_ locationDelegate: MapViewModelProtocol) {
        self.locationDelegate = locationDelegate
    }
}

extension MapViewModel: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationPermissions()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            timerObs?.dispose()
            locationDelegate?.currentLocationAt(location.coordinate)
            startDrivers()
        }
    }
}
