import UIKit

class AppCoordinator {
    
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
}
