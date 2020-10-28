import RxSwift

protocol DriverServiceProtocol {
    func fetchDrivers() -> Observable<[DriverModel]>
}

class DriverService: DriverServiceProtocol {
    func fetchDrivers() -> Observable<[DriverModel]> {
        return Observable.create { observer -> Disposable in
            let task = URLSession.shared.dataTask(with: URL(string: "https://sheetdb.io/api/v1/pc1ght2w5p69l")!) {
                data, _, error in
                
                if let error = error {
                    observer.onError(error)
                    return
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
            }
            
            task.resume()
            
            return Disposables.create {
                task.cancel()
            }
        }
    }
}
