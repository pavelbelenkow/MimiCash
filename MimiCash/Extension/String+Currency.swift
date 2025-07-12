import Foundation

// MARK: - String + Currency

extension String {
    
    var currencySymbol: String {
        switch self.uppercased() {
        case "RUB":
            return "₽"
        case "USD":
            return "$"
        case "EUR":
            return "€"
        default:
            return self
        }
    }
    
    /// Форматирует ввод суммы с учетом локали
    func formatInput() -> String {
        if isEmpty {
            return ""
        }
        
        let decimalSeparator = Locale.current.decimalSeparator ?? "."
        
        let cleanInput = self
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: Locale.current.groupingSeparator ?? " ", with: "")
        
        let allowedChars = CharacterSet.decimalDigits.union(CharacterSet(charactersIn: decimalSeparator))
        
        let isValidInput = cleanInput.allSatisfy { char in
            guard let scalar = char.unicodeScalars.first else { return false }
            return allowedChars.contains(scalar)
        }
        
        if !isValidInput {
            return self
        }
        
        let components = cleanInput.components(separatedBy: decimalSeparator)
        if components.count > 2 {
            return self
        }
        
        if cleanInput.hasSuffix(decimalSeparator) {
            return cleanInput
        }
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 0
        formatter.groupingSeparator = Locale.current.groupingSeparator
        formatter.decimalSeparator = Locale.current.decimalSeparator
        
        if let number = formatter.number(from: cleanInput) {
            return formatter.string(from: number) ?? cleanInput
        }
        
        return cleanInput
    }
}
