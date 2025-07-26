import Foundation

extension Decimal {
    func formattedAsPercent() -> String {
        let formatter = NumberFormatter()
        formatter.positiveFormat = "0.##%"
        formatter.maximumFractionDigits = 2
        
        return formatter.string(from: self as NSDecimalNumber) ?? "\(self)"
    }
}
