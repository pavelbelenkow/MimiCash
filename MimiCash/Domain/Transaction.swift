import Foundation

/// Модель транзакции
struct Transaction: Identifiable {
    let id: Int
    let account: BankAccount
    let category: Category
    let amount: Decimal
    let transactionDate: Date
    let comment: String?
}

extension Transaction {
    
    func formattedAmount() -> String {
        amount.formattedAsCurrency(code: account.currency)
    }
    
    func formattedDate() -> String {
        transactionDate.formatted(date: .omitted, time: .shortened)
    }
}

// MARK: - Hashable

extension Transaction: Hashable {
    static func == (lhs: Transaction, rhs: Transaction) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
