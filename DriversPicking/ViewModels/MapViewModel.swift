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
    private let driverService: DriverServiceProtocol
    
    // MARK: - Subjects
    var drivers = BehaviorSubject(value: [DriverViewModel]())
    var pickedDriver: BehaviorSubject<DriverViewModel?> = BehaviorSubject(value: nil)

    
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
                
                self.drivers.onNext(drivers)
                
                Observable<Int>
                    .interval(RxTimeInterval.seconds(5), scheduler: MainScheduler.instance)
                    .subscribe { [weak self ] _ in
                        self?.updateDriver()
                    }
                    .disposed(by: self.disposeBag)
            }, onError: { [weak self ] error in
                self?.drivers.onError(error)
            })
            .disposed(by: disposeBag)
    }
    
    private func updateDriver() {
        guard let currentLocation = manager?.location?.coordinate else {
            return
        }
        do {
            try drivers.value().enumerated().forEach { (index, driver) in
                driver.annotation.coordinate = currentLocation.generateRandomCoordinate()
            }
        } catch {
            drivers.onError(error)
        }
    }
    
    func pickDriver(with annotation: DriverAnnotation?) {
        guard let annotation = annotation else {
            pickedDriver.onNext(nil)
            return
        }
        do {
            let driver = try drivers.value().first(where: { $0.driverAnnotationId == annotation.id })
            pickedDriver.onNext(driver)
        } catch {
            drivers.onError(error)
        }
        
    }
}

extension MapViewModel: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationPermissions()
    }
}
