import UIKit
import MapKit
import RxSwift
import CoreLocation

class MapViewController: UIViewController {

    
    // MARK: - Properties
    private(set) var mapView: MKMapView = {
        let mapView = MKMapView()
        mapView.translatesAutoresizingMaskIntoConstraints = false
        
        return mapView
    }()
    
    private(set) var driverView: DriverView = {
        let view = DriverView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private(set) var viewModel: MapViewModel?
    private(set) var currentLocationAnnotation = MKPointAnnotation()
    private(set) var disposeBag = DisposeBag()
    private(set) var selectedAnnotation: DriverAnnotation?
    
    // MARK: - Init
    init(viewModel: MapViewModel) {
        super.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel
        self.viewModel?.setDelegate(self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func loadView() {
        super.loadView()
        configureViewController()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBindings()
        mapView.delegate = self
    }
    
    
    // MARK: - Setup
    private func configureViewController() {
        view.addSubview(mapView)
        view.addSubview(driverView)
        
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            driverView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            driverView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            driverView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
        ])
        
    }
    
    private func setCurrentLocation(with currentLocation: CLLocationCoordinate2D) {
        mapView.setRegion(getRegion(from: currentLocation), animated: true)
        
        let mkAnnotation: MKPointAnnotation = MKPointAnnotation()
        mkAnnotation.coordinate = currentLocation
        self.currentLocationAnnotation = mkAnnotation
        
        mapView.addAnnotation(mkAnnotation)
    }
    
    private func setupBindings() {
        viewModel?
            .drivers
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] drivers in
                drivers.forEach { (driver) in
                    self?.mapView.addAnnotation(driver.annotation)
                }
            }, onError: { error in
                print(error)
            })
            .disposed(by: disposeBag)
        
        viewModel?
            .presentedDriver
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self]  driver in
                guard let self = self else {
                    return
                }
                self.driverView.dateLabel.text = Date().convertToFormat()
                if let driver = driver {
                    self.driverView.nameLabel.text = driver.displayName
                    driver
                    .getAddress(with: driver.annotation.coordinate)
                    .bind(to: self.driverView.addressLabel.rx.text)
                    .disposed(by: self.disposeBag)
                    
                    driver
                        .downloadImage()
                        .bind(to: self.driverView.profileImageView.rx.image)
                        .disposed(by: self.disposeBag)
                }
                
                
                
            }, onError: { error in
                print(error)
            })
            .disposed(by: disposeBag)
    }
    
    private func getRegion(from currentLocation: CLLocationCoordinate2D) -> MKCoordinateRegion {
        return MKCoordinateRegion(
            center: currentLocation,
            latitudinalMeters: 1000,
            longitudinalMeters: 1000
        )
    }
}

// MARK: - MapViewModelProtocol
extension MapViewController: MapViewModelProtocol {
    func currentLocationAt(_ currentLocation: CLLocationCoordinate2D?) {
        guard let currentLocation = currentLocation else {
            return
        }
        setCurrentLocation(with: currentLocation)
    }
}

// MARK: - MKMapViewDelegate
extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let ann = view.annotation as? DriverAnnotation else { return }
        
        if let selectedAnnotation = self.selectedAnnotation {
            mapView.removeAnnotation(selectedAnnotation)
            mapView.addAnnotation(selectedAnnotation)
            self.selectedAnnotation = selectedAnnotation.id == ann.id ?  nil : ann
        } else {
            self.selectedAnnotation = ann
        }
        viewModel?.pickDriver(with: selectedAnnotation)
        
        mapView.removeAnnotation(ann)
        mapView.addAnnotation(ann)
    }
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var pinView: MKAnnotationView?
        if annotation.coordinate == currentLocationAnnotation.coordinate {
            pinView = MKAnnotationView(
                annotation: annotation,
                reuseIdentifier: PinIdent.user.rawValue
            )
            pinView?.image = Assets.image(.locationPin)
        } else {
            if let ann = annotation as? DriverAnnotation {
                if let selectedAnnotation = selectedAnnotation,
                    ann.id == selectedAnnotation.id {
                    pinView = MKAnnotationView(
                        annotation: annotation,
                        reuseIdentifier: PinIdent.driverSelected.rawValue
                    )
                    pinView?.image = Assets.image(.sportCarSelected)
                } else {
                    pinView = MKAnnotationView(
                        annotation: annotation,
                        reuseIdentifier: PinIdent.driver.rawValue
                    )
                    pinView?.image = Assets.image(.sportCar)
                }
            }
            
        }
        return pinView
    }
}
