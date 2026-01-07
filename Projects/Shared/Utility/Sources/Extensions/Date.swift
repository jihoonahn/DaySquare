import Foundation

extension Date {
     public func toString(format: String? = nil) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.timeZone = TimeZone.current
        
        if let format = format {
            formatter.dateFormat = format
        } else {
            formatter.dateStyle = .long
            formatter.timeStyle = .none
        }
        
        return formatter.string(from: self)
    }

    public func isoTimeString() -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate, .withTime, .withColonSeparatorInTime]
        return formatter.string(from: self)
    }
}
