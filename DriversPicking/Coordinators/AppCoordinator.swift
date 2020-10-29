import UIKit

protocol AppCoordinatorProtocol: class {
    func showDriverInfo(driver: DriverViewModel?)
}

class AppCoordinator: AppCoordinatorProtocol {
    
    // MARK: - Properties
    private let window: UIWindow
    private var rootViewController: UIViewController?
    let label = UILabel()
    
    // MARK: - Init
    init(window: UIWindow) {
        self.window = window
    }
    
    func start() {
        self.rootViewController = MapViewController(viewModel: MapViewModel())
        window.rootViewController = rootViewController
        window.makeKeyAndVisible()
    }
    
    private func addDriverInfoView() {
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "no driver"
        rootViewController?.view.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: rootViewController!.view.safeAreaLayoutGuide.topAnchor, constant: 30),
            label.leadingAnchor.constraint(equalTo: rootViewController!.view.leadingAnchor, constant: 30),
            label.trailingAnchor.constraint(equalTo: rootViewController!.view.trailingAnchor, constant: -30)
        ])
    }
}

extension AppCoordinator {
    func showDriverInfo(driver: DriverViewModel?) {
        label.text = "\(driver?.annotation.coordinate.latitude)"
    }
}
