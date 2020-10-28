import MapKit
struct DriverViewModel {
    // MARK: - Properties
    private var driver: DriverModel
    
    var annotation: DriverAnnotation
    
    var displayName: String {
        return driver.name
    }
    
    // MARK: - Init
    init(
        driver: DriverModel,
        annotation: DriverAnnotation
    ) {
        self.driver = driver
        self.annotation = annotation
    }
}