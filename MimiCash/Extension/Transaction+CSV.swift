import Foundation

// MARK: - Transaction + CSV Parsing

extension Transaction {
    
    static func parseCSV(from url: URL) async throws -> [Transaction] {
        var result: [Transaction] = []
        var isFirstLine = true
        
        for try await line in url.lines {
            if isFirstLine {
                isFirstLine = false
                continue
            }
            
            let fields = parseCSVLine(line)
            if let transaction = fromCSVFields(fields) {
                result.append(transaction)
            }
        }
        
        return result
    }
    
    private static func parseCSVLine(_ line: String) -> [String] {
        var fields: [String] = []
        var currentField = ""
        var insideQuotes = false
        var iterator = line.makeIterator()
        
        while let char = iterator.next() {
            if char == "\"" {
                if insideQuotes {
                    if let nextChar = iterator.next() {
                        if nextChar == "\"" {
                            currentField.append("\"")
                        } else {
                            insideQuotes = false
                            if nextChar == "," {
                                fields.append(currentField)
                                currentField = ""
                            } else {
                                currentField.append(nextChar)
                            }
                        }
                    } else {
                        insideQuotes = false
                    }
                } else {
                    insideQuotes = true
                }
            } else if char == "," && !insideQuotes {
                fields.append(currentField)
                currentField = ""
            } else {
                currentField.append(char)
            }
        }
        fields.append(currentField)
        return fields.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
    }
    
    private static func fromCSVFields(_ fields: [String]) -> Transaction? {
        guard
            fields.count >= 12,
            let id = Int(fields[0]),
            let accountId = Int(fields[1]),
            let accountBalance = Decimal(string: fields[3]),
            let categoryId = Int(fields[5]),
            let emoji = fields[7].first,
            let isIncome = Bool(fields[8].lowercased()),
            let amount = Decimal(string: fields[9]),
            let transactionDate = isoDateFormatter.date(from: fields[10])
        else {
            assertionFailure("Invalid CSV line: one or more fields are invalid")
            return nil
        }
        
        let account = BankAccount(
            id: accountId,
            name: fields[2],
            balance: accountBalance,
            currency: fields[4]
        )
        
        let category = Category(
            id: categoryId,
            name: fields[6],
            emoji: emoji,
            isIncome: isIncome ? .income : .outcome
        )
        
        return Transaction(
            id: id,
            account: account,
            category: category,
            amount: amount,
            transactionDate: transactionDate,
            comment: fields[11]
        )
    }
    
    private static let isoDateFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()
}
