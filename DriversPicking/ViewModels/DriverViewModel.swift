struct DriverViewModel {
    // MARK: - Properties
    private var driver: DriverModel
    
    var annotation: Annotation
    
    var displayName: String {
        return driver.name
    }
    
    // MARK: - Init
    init(
        driver: DriverModel,
        annotation: Annotation
    ) {
        self.driver = driver
        self.annotation = annotation
    }
}
