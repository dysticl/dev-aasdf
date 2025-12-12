import Foundation

extension String {
    func toISO8601Date() -> Date? {
        let formatter = ISO8601DateFormatter()
        // Try with fractional seconds first
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = formatter.date(from: self) { return date }

        // Try standard
        formatter.formatOptions = [.withInternetDateTime]
        return formatter.date(from: self)
    }
}

extension Date {
    var isOverdue: Bool {
        return self < Date()
    }
}
