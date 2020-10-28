//
//  ViewController.swift
//  DriversPicking
//
//  Created by Miguel Teixeira on 20/10/2020.
//

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
    
    private(set) var viewModel: MapViewModel?
    
    private(set) var currentLocation: CLLocationCoordinate2D?
    private(set) var disposeBag = DisposeBag()
    private(set) var selectedAnnotation: Annotation?
    
    
    override func loadView() {
        super.loadView()
        configureViewController()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = MapViewModel(locationDelegate: self)
        setupBindings()
        mapView.delegate = self
    }
    
    
    // MARK: - Setup
    private func configureViewController() {
        view.addSubview(mapView)
        
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
    }
    
    private func setCurrentLocation(with currentLocation: CLLocationCoordinate2D) {
        self.currentLocation = currentLocation
        mapView.setRegion(getRegion(from: currentLocation), animated: true)
        
        let mkAnnotation: MKPointAnnotation = MKPointAnnotation()
        mkAnnotation.coordinate = currentLocation
        mapView.addAnnotation(mkAnnotation)
    }
    
    private func setupBindings() {
        viewModel?
            .drivers
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { drivers in
                drivers.forEach { (driver) in
                    self.setLocation(on: driver)
                }
            })
            .disposed(by: disposeBag)
    }
            
    private func setLocation(on driverLocation: DriverViewModel) {
        mapView.annotations.forEach({ annotation in
            if let annotation = annotation as? Annotation, annotation.id == driverLocation.annotation.id {
                self.mapView.removeAnnotation(annotation)
            }
        })
        
        mapView.addAnnotation(driverLocation.annotation)
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
//    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
//        guard let currentLocation = currentLocation else {
//            return
//        }
//
//        mapView.setRegion(getRegion(from: currentLocation), animated: true)
//    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let ann = view.annotation as? Annotation else { return }
        
        if let selectedAnnotation = selectedAnnotation {
            self.mapView.removeAnnotation(selectedAnnotation)
            self.mapView.addAnnotation(selectedAnnotation)
            
            if selectedAnnotation.id == ann.id {
                self.selectedAnnotation = nil
            } else {
                self.selectedAnnotation = ann
            }
        } else {
            self.selectedAnnotation = ann
        }
        
        self.mapView.removeAnnotation(ann)
        self.mapView.addAnnotation(ann)
        
    }
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let currentLocation = currentLocation else {
            return nil
        }
        if annotation is MKUserLocation {
            return nil;
        } else {
            let pinIdent = "PinLocation"
            var pinView: MKAnnotationView?
            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: pinIdent) {
                dequeuedView.annotation = annotation
                pinView = dequeuedView
            } else {
                if annotation.coordinate.latitude == currentLocation.latitude,
                   annotation.coordinate.longitude == currentLocation.longitude {
                    pinView = MKAnnotationView(annotation: annotation, reuseIdentifier: "User");
                    pinView?.image = UIImage(named: "location-pin")
                } else {
                    if let ann = annotation as? Annotation {
                        if let selectedAnnotation = selectedAnnotation,
                            ann.id == selectedAnnotation.id {
                            pinView = MKAnnotationView(annotation: annotation, reuseIdentifier: "Driver-selected");
                            pinView?.image = UIImage(named: "sport-car-selected")
                        } else {
                            pinView = MKAnnotationView(annotation: annotation, reuseIdentifier: "Driver");
                            pinView?.image = UIImage(named: "sport-car")
                        }
                    }
                    
                }
            }
            return pinView;
        }
    }
}
