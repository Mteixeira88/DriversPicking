import RxSwift

class FoundDriverService {
    static let imageCache = NSCache<NSString, UIImage>()
    
    func downloadImage(from url: String?) -> Observable<UIImage> {
        return Observable.create { (observer) -> Disposable in
            guard let imageString = url,
                let url = URL(string: imageString) else {
                observer.onNext(Assets.image(.locationPin))
                return Disposables.create {
                }
            }
            
            if let imageFromCache = FoundDriverService.imageCache.object(forKey: NSString(string: imageString)) {
                observer.onNext(imageFromCache)
                return Disposables.create()
            }
            
            URLSession.shared.dataTask(with: url, completionHandler: { (data, _, error) -> Void in
                if error != nil {
                    observer.onNext(Assets.image(.locationPin))
                    return
                }
                if let data = data {
                    guard let imageToCache = UIImage(data: data) else { return }
                    FoundDriverService.imageCache.setObject(imageToCache, forKey: NSString(string: imageString))
                    observer.onNext(imageToCache)
                }
            }).resume()
            
            return Disposables.create()
        }
    }
}
