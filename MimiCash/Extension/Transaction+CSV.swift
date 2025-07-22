import Foundation

// MARK: - Transaction + CSV Parsing

extension Transaction {
    
    static func fromCSVFile(url: URL) async throws -> [Transaction] {
        let parser: CSVParser = CSVParserImp()
        let csv = try await parser.parseFile(from: url)
        return csv.rows.compactMap { Transaction.parse(from: $0) }
    }
    
    private static func parse(from row: [String: String]) -> Transaction? {
        guard
            let idStr = row["id"], let id = Int(idStr),
            let accountIdStr = row["account.id"], let accountId = Int(accountIdStr),
            let accountBalanceStr = row["account.balance"], let balance = Decimal(string: accountBalanceStr),
            let currency = row["account.currency"],
            let accountName = row["account.name"],
            let categoryIdStr = row["category.id"], let categoryId = Int(categoryIdStr),
            let emojiStr = row["category.emoji"], let emoji = emojiStr.first,
            let categoryName = row["category.name"],
            let isIncomeStr = row["category.isIncome"], let isIncome = Bool(isIncomeStr),
            let amountStr = row["amount"], let amount = Decimal(string: amountStr),
            let dateStr = row["transactionDate"], let date = ISO8601DateFormatter.isoDateFormatter.date(from: dateStr)
        else { return nil }
        
        let account = BankAccount(
            id: accountId,
            name: accountName,
            balance: balance,
            currency: currency
        )
        
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
            transactionDate: date,
            comment: row["comment"] ?? ""
        )
    }
}
