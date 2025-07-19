import Foundation

extension Transaction {
    
    func toTransactionRequest() -> TransactionRequestBody {
        let dateFormatter = ISO8601DateFormatter()
        let dateString = dateFormatter.string(from: transactionDate)
        
        return TransactionRequestBody(
            accountId: account.id,
            categoryId: category.id,
            amount: String(describing: amount),
            transactionDate: dateString,
            comment: comment
        )
    }
}
