import Foundation

// MARK: - TransactionsProvider Protocol

protocol TransactionsProvider {
    var service: TransactionsService { get }
    
    func fetchTransactions(
        accountId: Int,
        from startDate: Date,
        to endDate: Date,
        direction: Direction
    ) async throws -> TransactionsOutput
}

// MARK: - Default Implementation

extension TransactionsProvider {
    
    func fetchTransactions(
        accountId: Int,
        from startDate: Date,
        to endDate: Date,
        direction: Direction
    ) async throws -> TransactionsOutput {
        let transactions = try await service.fetchTransactions(
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
} 
