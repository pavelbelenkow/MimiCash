import Foundation

/// Модель банковского счета пользователя
struct BankAccount {
    let id: Int
    let name: String
    let balance: Decimal
    let currency: String
}
