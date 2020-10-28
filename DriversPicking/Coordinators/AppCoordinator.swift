import UIKit

class AppCoordinator {
    
    // MARK: - Properties
    private let window: UIWindow
    
    // MARK: - Init
    init(window: UIWindow) {
        self.window = window
        start()
    }
    
    
    func start() {
        let rootViewController = MapViewController()
        window.rootViewController = rootViewController
        window.makeKeyAndVisible()
    }
}
