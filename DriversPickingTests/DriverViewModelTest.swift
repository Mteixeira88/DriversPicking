import XCTest
import MapKit
import RxTest
import RxSwift

@testable import DriversPicking

class DriverViewModelTest: XCTestCase {
    
    var driverViewModel: DriverViewModel!
    var annotation: DriverAnnotation!
    var disposeBag: DisposeBag!
    var testDriverModel: DriverModel!
    
    let testingCoordinates = CLLocationCoordinate2D(latitude: 37.785834, longitude: -122.406417)

    override func setUp() {
        super.setUp()
        annotation = DriverAnnotation()
        annotation.coordinate = testingCoordinates
        testDriverModel = DriverModel(
                id: UUID().uuidString,
                name: "Testing user",
                image: ""
            )
        driverViewModel = DriverViewModel(
            driver: testDriverModel,
            annotation: annotation
        )
        disposeBag = DisposeBag()
    }
    
    override func tearDown() {
        driverViewModel = nil
        annotation = nil
        disposeBag = nil
        testDriverModel = nil
        super.tearDown()
    }
    
    func test_get_correct_address() throws {
        let expectCorrectAddress = expectation(description: "Does not contain correct address")
        let correctAddress =
        """
        1 Stockton St
        San Francisco CA 94108
        United States
        """
        
        driverViewModel
            .getAddress(with: testingCoordinates)
            .subscribe(onNext: { address in
                XCTAssertEqual(address, correctAddress)
                expectCorrectAddress.fulfill()
            })
            .disposed(by: disposeBag)
        
        wait(for: [expectCorrectAddress], timeout: 0.5)
    }
    
    func test_get_wrong_address() throws {
        let expectWrongAddress = expectation(description: "Does not contain wrong address")
        let wrongAddress =
        """
        2 Stockton St
        San Francisco CA 94108
        United States
        """
        
        driverViewModel
            .getAddress(with: testingCoordinates)
            .subscribe(onNext: { address in
                XCTAssertNotEqual(address, wrongAddress)
                expectWrongAddress.fulfill()
            })
            .disposed(by: disposeBag)
        
        wait(for: [expectWrongAddress], timeout: 0.5)
    }
    
    
    func test_get_placeholder_image() throws {
        let expectPlaceholderImage = expectation(description: "Does not contain placeholder image")
        
        driverViewModel
            .downloadImage()
            .subscribe(onNext: { image in
                XCTAssertEqual(image, Assets.image(.locationPin))
                expectPlaceholderImage.fulfill()
            })
            .disposed(by: disposeBag)
        
        wait(for: [expectPlaceholderImage], timeout: 0.1)
    }
    
    func test_dowloaded_image() throws {
        let expectDownloadImage = expectation(description: "Does not contain downloaded image")
        
        let url = "https://photojournal.jpl.nasa.gov/jpeg/PIA23689.jpg"
        testDriverModel.image = url
        driverViewModel = DriverViewModel(driver: testDriverModel, annotation: annotation)
        
        driverViewModel
            .downloadImage()
            .subscribe(onNext: { image in
                let imageData = image.pngData()
                let testImage = Assets.image(.testImage).pngData()
                XCTAssertEqual(imageData, testImage)
                expectDownloadImage.fulfill()
            })
            .disposed(by: disposeBag)
        
        wait(for: [expectDownloadImage], timeout: 6)
    }
    
    func test_cached_dowloaded_image() throws {
        let expectDownloadImage = expectation(description: "Does not contain download image")
        let expectCachedImage = expectation(description: "Does not contain cached image")
        
        let url = "https://photojournal.jpl.nasa.gov/jpeg/PIA23689.jpg"
        testDriverModel.image = url
        driverViewModel = DriverViewModel(driver: testDriverModel, annotation: annotation)
        
        driverViewModel
            .downloadImage()
            .subscribe(onNext: { image in
                let imageData = image.pngData()
                let testImage = Assets.image(.testImage).pngData()
                XCTAssertEqual(imageData, testImage)
                expectDownloadImage.fulfill()
            })
            .disposed(by: disposeBag)
        wait(for: [expectDownloadImage], timeout: 6)
        
        driverViewModel
            .downloadImage()
            .subscribe(onNext: { image in
                let imageData = image.pngData()
                let testImage = Assets.image(.testImage).pngData()
                XCTAssertEqual(imageData, testImage)
                expectCachedImage.fulfill()
            })
            .disposed(by: disposeBag)
        
        wait(for: [expectCachedImage], timeout: 0)
    }
}
