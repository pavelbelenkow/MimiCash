import Foundation

struct TransactionsOutput {
    let transactions: [Transaction]
    let total: Decimal
    
    func totalAmountFormatted() -> String {
        let code = transactions.map { $0.account.currency }.first ?? ""
        return total.formattedAsCurrency(code: code)
    }
}
