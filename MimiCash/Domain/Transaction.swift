import Foundation

/// Модель транзакции
struct Transaction {
    let id: Int
    let account: BankAccount
    let category: Category
    let amount: Decimal
    let transactionDate: Date
    let comment: String?
}
