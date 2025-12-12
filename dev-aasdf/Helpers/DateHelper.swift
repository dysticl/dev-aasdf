import Foundation

extension String {
    func toISO8601Date() -> Date? {
        // Try ISO8601DateFormatter with fractional seconds + timezone
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = isoFormatter.date(from: self) { return date }

        // Try standard ISO8601 with timezone
        isoFormatter.formatOptions = [.withInternetDateTime]
        if let date = isoFormatter.date(from: self) { return date }

        // Fallback: Handle dates WITHOUT timezone (e.g., "2025-12-12T21:08:07.771393")
        // The API returns this format, so we assume UTC
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(identifier: "UTC")

        // Try with fractional seconds
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
        if let date = dateFormatter.date(from: self) { return date }

        // Try with fewer fractional digits
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        if let date = dateFormatter.date(from: self) { return date }

        // Try without fractional seconds
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        return dateFormatter.date(from: self)
    }
}

extension Date {
    var isOverdue: Bool {
        return self < Date()
    }
}
