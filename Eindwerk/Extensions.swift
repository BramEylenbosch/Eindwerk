import Foundation

extension DateFormatter {
    static var short: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }
}

struct CoordinateConverter {
    static func convertDMSToDecimalDegrees(degrees: Int, minutes: Int, seconds: Int, direction: String) -> Double {
        var decimalDegrees = Double(degrees) + Double(minutes) / 60.0 + Double(seconds) / 3600.0
        if direction == "S" || direction == "W" {
            decimalDegrees = -decimalDegrees
        }
        return decimalDegrees
    }
}
