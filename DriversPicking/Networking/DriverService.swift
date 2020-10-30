import RxSwift

protocol DriverServiceProtocol {
    func fetchDrivers() -> Observable<[DriverModel]>
}

class DriverService: DriverServiceProtocol {
    static let imageCache = NSCache<NSString, UIImage>()
    
    func fetchDrivers() -> Observable<[DriverModel]> {
        return Observable.create { observer -> Disposable in
            URLSession.shared.dataTask(
                with:  URL(string: "https://sheetdb.io/api/v1/pc1ght2w5p69l")!,
                completionHandler: { (data, _, error) -> Void in
                    if let error = error {
                        observer.onError(error)
                    }
                    
                    guard let data = data else {
                        return
                    }
                    
                    do {
                        let drivers = try JSONDecoder().decode([DriverModel].self, from: data)
                        observer.onNext(drivers)
                    } catch {
                        observer.onError(error)
                    }
                }).resume()
            
            return Disposables.create()
        }
    }
}
