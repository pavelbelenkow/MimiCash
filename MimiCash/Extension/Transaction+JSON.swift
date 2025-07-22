import Foundation

// MARK: - Transaction + JSON Conversion

extension Transaction {
    
    /// Перечисление ошибок парсинга JSON
    enum ParseError: Error, Equatable {
        case invalidTopLevelStructure
        case missingOrInvalidField(fieldName: String)
        case invalidAccountFields
        case invalidCategoryFields
        case invalidDateFormat
    }
    
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
            "transactionDate": ISO8601DateFormatter.isoDateFormatter.string(from: transactionDate),
        ]
        
        if let comment {
            dict["comment"] = comment
        }
        
        return dict
    }
    
    /// Парсит Foundation JSON object в структуру `Transaction`
    static func parse(jsonObject: Any) throws -> Transaction? {
        guard let dict = jsonObject as? [String: Any] else {
            throw ParseError.invalidTopLevelStructure
        }
        
        guard let id = dict["id"] as? Int else {
            throw ParseError.missingOrInvalidField(fieldName: "id")
        }
        
        guard let accountDict = dict["account"] as? [String: Any] else {
            throw ParseError.missingOrInvalidField(fieldName: "account")
        }
        
        guard let categoryDict = dict["category"] as? [String: Any] else {
            throw ParseError.missingOrInvalidField(fieldName: "category")
        }
        
        guard
            let amountString = dict["amount"] as? String,
            let amount = Decimal(string: amountString)
        else {
            throw ParseError.missingOrInvalidField(fieldName: "amount")
        }
        
        guard let dateString = dict["transactionDate"] as? String else {
            throw ParseError.missingOrInvalidField(fieldName: "transactionDate")
        }
        
        guard let transactionDate = ISO8601DateFormatter.isoDateFormatter.date(from: dateString) else {
            throw ParseError.invalidDateFormat
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
            throw ParseError.invalidAccountFields
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
            throw ParseError.invalidCategoryFields
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
}
