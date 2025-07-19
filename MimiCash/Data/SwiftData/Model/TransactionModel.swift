import Foundation
import SwiftData

@Model
final class TransactionModel {
    var id: Int
    var accountId: Int
    var accountName: String
    var accountBalance: Decimal
    var accountCurrency: String
    var categoryId: Int
    var categoryName: String
    var categoryEmoji: String
    var categoryIsIncome: Bool
    var amount: Decimal
    var transactionDate: Date
    var comment: String?
    
    init(from transaction: Transaction) {
        self.id = transaction.id
        self.accountId = transaction.account.id
        self.accountName = transaction.account.name
        self.accountBalance = transaction.account.balance
        self.accountCurrency = transaction.account.currency
        self.categoryId = transaction.category.id
        self.categoryName = transaction.category.name
        self.categoryEmoji = String(transaction.category.emoji)
        self.categoryIsIncome = transaction.category.isIncome == .income
        self.amount = transaction.amount
        self.transactionDate = transaction.transactionDate
        self.comment = transaction.comment
    }
    
    func toTransaction() -> Transaction {
        let account = BankAccount(
            id: accountId,
            name: accountName,
            balance: accountBalance,
            currency: accountCurrency
        )
        
        let category = Category(
            id: categoryId,
            name: categoryName,
            emoji: Character(categoryEmoji),
            isIncome: categoryIsIncome ? .income : .outcome
        )
        
        return Transaction(
            id: id,
            account: account,
            category: category,
            amount: amount,
            transactionDate: transactionDate,
            comment: comment
        )
    }
}
