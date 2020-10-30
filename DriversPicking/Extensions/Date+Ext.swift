import Foundation

extension Date {
    static let dateFormatter: Foundation.DateFormatter = {
        let formatter = Foundation.DateFormatter()
        formatter.locale = Locale.current
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        return formatter
    }()
    
    func convertToFormat() -> String {
        Date.dateFormatter.string(from: self)
    }
}
