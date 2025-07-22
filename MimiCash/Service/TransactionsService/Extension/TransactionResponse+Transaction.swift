import Foundation

extension TransactionResponse {
    
    func toTransaction() -> Transaction {
        let dateFormatter = ISO8601DateFormatter()
        let transactionDate = dateFormatter.date(from: transactionDate) ?? Date()
        
        return Transaction(
            id: id,
            account: account.toBankAccount(),
            category: category.toCategory(),
            amount: Decimal(string: amount) ?? 0,
            transactionDate: transactionDate,
            comment: comment
        )
    }
}
