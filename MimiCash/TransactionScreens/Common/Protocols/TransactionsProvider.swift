import Foundation

// MARK: - TransactionsProvider Protocol

protocol TransactionsProvider {
    var transactionsService: TransactionsService { get }
    
    func fetchTransactions(
        accountId: Int,
        from startDate: Date,
        to endDate: Date,
        direction: Direction
    ) async -> TransactionsOutput
    
    func post(transaction: Transaction) async throws -> Transaction
    func update(transaction: Transaction) async throws -> Transaction
    func delete(transactionId: Int) async throws
}

// MARK: - Default Implementation

extension TransactionsProvider {
    
    func fetchTransactions(
        accountId: Int,
        from startDate: Date,
        to endDate: Date,
        direction: Direction
    ) async -> TransactionsOutput {
        let transactions = await transactionsService.fetchTransactions(
            accountId: accountId,
            from: startDate,
            to: endDate
        )
        
        guard !transactions.isEmpty else {
            return TransactionsOutput(
                transactions: [],
                total: .zero
            )
        }
        
        let filteredByDirection = transactions
            .filter { $0.category.isIncome == direction }
        let total = filteredByDirection
            .reduce(.zero) { $0 + $1.amount }
        
        return TransactionsOutput(
            transactions: filteredByDirection,
            total: total
        )
    }
    
    func post(transaction: Transaction) async throws -> Transaction {
        try await transactionsService.post(transaction: transaction)
    }
    
    func update(transaction: Transaction) async throws -> Transaction {
        try await transactionsService.update(transaction: transaction)
    }
    
    func delete(transactionId: Int) async throws {
        try await transactionsService.delete(transactionId: transactionId)
    }
}

