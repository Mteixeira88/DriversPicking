import Foundation

extension Date {
    
    func convertToFormat() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy 'at' HH:mm:ss"
        dateFormatter.locale = Locale.current
        return dateFormatter.string(from: self)
    }
    
}
