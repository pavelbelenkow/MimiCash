import Foundation

// MARK: - Transaction + JSON Conversion

extension Transaction {
    
    /// Возвращает представление транзакции в виде Foundation JSON object
    var jsonObject: Any {
        var dict: [String: Any] = [
            "id": id,
            "account": [
                "id": account.id,
                "name": account.name,
                "balance": account.balance.description,
                "currency": account.currency
            ],
            "category": [
                "id": category.id,
                "name": category.name,
                "emoji": String(category.emoji),
                "isIncome": category.isIncome == .income
            ],
            "amount": amount.description,
            "transactionDate": Self.isoDateFormatter.string(from: transactionDate),
        ]
        
        if let comment {
            dict["comment"] = comment
        }
        
        return dict
    }
    
    /// Парсит Foundation JSON object в структуру `Transaction`
    static func parse(jsonObject: Any) -> Transaction? {
        guard
            let dict = jsonObject as? [String: Any],
            let id = dict["id"] as? Int,
            let accountDict = dict["account"] as? [String: Any],
            let categoryDict = dict["category"] as? [String: Any],
            let amountString = dict["amount"] as? String,
            let amount = Decimal(string: amountString),
            let dateString = dict["transactionDate"] as? String,
            let transactionDate = isoDateFormatter.date(from: dateString)
        else {
            assertionFailure("Transaction: invalid top-level structure or basic fields")
            return nil
        }
        
        let comment = dict["comment"] as? String
        
        // BankAccount
        guard
            let accountId = accountDict["id"] as? Int,
            let accountName = accountDict["name"] as? String,
            let balanceString = accountDict["balance"] as? String,
            let balance = Decimal(string: balanceString),
            let currency = accountDict["currency"] as? String
        else {
            assertionFailure("Transaction: invalid BankAccount fields")
            return nil
        }
        
        let account = BankAccount(
            id: accountId,
            name: accountName,
            balance: balance,
            currency: currency
        )
        
        // Category
        guard
            let categoryId = categoryDict["id"] as? Int,
            let categoryName = categoryDict["name"] as? String,
            let emojiString = categoryDict["emoji"] as? String,
            let emoji = emojiString.first,
            let isIncome = categoryDict["isIncome"] as? Bool
        else {
            assertionFailure("Transaction: invalid Category fields")
            return nil
        }
        
        let category = Category(
            id: categoryId,
            name: categoryName,
            emoji: emoji,
            isIncome: isIncome ? .income : .outcome
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
    
    private static let isoDateFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()
}
