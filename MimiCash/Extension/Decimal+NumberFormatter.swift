import Foundation

extension Decimal {
    
    var stringValue: String {
        NSDecimalNumber(decimal: self).stringValue
    }
    
    func formattedAsCurrency(code: String) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = code
        formatter.currencySymbol = code.currencySymbol
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 0
        
        return formatter.string(from: self as NSDecimalNumber) ?? "\(self)"
    }
}
