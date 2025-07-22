import Foundation

// MARK: - TransactionsSortable Protocol

protocol TransactionsSortable: AnyObject {
    var sort: TransactionsSort { get set }
    var sortedOutput: TransactionsOutput? { get }
    
    func handleSortSelection(_ sort: TransactionsSort)
}

// MARK: - Default Implementation

extension TransactionsSortable {
    
    func handleSortSelection(_ sort: TransactionsSort) {
        self.sort = sort
    }
}

// MARK: - TransactionsSortable + TransactionsViewModel

extension TransactionsSortable where Self: TransactionsViewModel {
    
    var sortedOutput: TransactionsOutput? {
        guard case let .success(output) = state else { return nil }
        let sorted = sortTransactions(output.transactions)
        return TransactionsOutput(transactions: sorted, total: output.total)
    }
    
    private func sortTransactions(_ transactions: [Transaction]) -> [Transaction] {
        switch sort {
        case .date:
            return transactions.sorted { $0.transactionDate > $1.transactionDate }
        case .amount:
            return transactions.sorted { $0.amount > $1.amount }
        }
    }
}
