import Foundation

/// Модель банковского счета пользователя
struct BankAccount {
    let id: Int
    let name: String
    let balance: Decimal
    let currency: String
}

// MARK: - Methods

extension BankAccount {
    
    func formattedBalance() -> String {
        balance.formattedAsCurrency(code: currency)
    }
}
