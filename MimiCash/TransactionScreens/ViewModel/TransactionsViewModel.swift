import Foundation

// MARK: - TransactionsViewModel Protocol

protocol TransactionsViewModel {
    var direction: Direction { get }
    var state: ViewState<TransactionsOutput> { get }
    var sort: TransactionsSort { get set }
    var sortedOutput: TransactionsOutput? { get }
    var title: String { get }
    
    func loadTransactions(
        from startDate: Date,
        to endDate: Date
    ) async
}

@Observable
final class TransactionsViewModelImp: TransactionsViewModel {
    
    // MARK: - Private Properties
    private let service: TransactionsService
    
    // MARK: - Properties
    var direction: Direction
    var state: ViewState<TransactionsOutput> = .idle
    var sort: TransactionsSort = .date
    
    var sortedOutput: TransactionsOutput? {
        guard case let .success(output) = state else { return nil }
        let sorted = sortTransactions(output.transactions)
        return TransactionsOutput(transactions: sorted, total: output.total)
    }
    
    var title: String {
        (direction == .income ?
        Tab.incomes.label : Tab.outcomes.label) + " cегодня"
    }
    
    // MARK: - Init
    init(
        direction: Direction,
        service: TransactionsService = TransactionsServiceImp()
    ) {
        self.service = service
        self.direction = direction
    }
    
    // MARK: - Methods
    func loadTransactions(
        from startDate: Date,
        to endDate: Date
    ) async {
        state = .loading
        
        do {
            let transactions = try await service
                .fetchTransactions(
                    accountId: 1, // в будущем будем загружать все счета пользователя и брать `accountId` оттуда
                    from: startDate,
                    to: endDate
                )
            
            guard !transactions.isEmpty else {
                return state = .success(
                    TransactionsOutput(
                        transactions: [],
                        total: .zero
                    )
                )
            }
            
            let filteredByDirection = transactions
                .filter { $0.category.isIncome == direction }
            let total = filteredByDirection
                .reduce(.zero) { $0 + $1.amount }
            
            state = .success(
                TransactionsOutput(
                    transactions: filteredByDirection,
                    total: total
                )
            )
        } catch {
            state = .error(error.localizedDescription)
        }
    }
    
    // MARK: - Private Methods
    private func sortTransactions(_ transactions: [Transaction]) -> [Transaction] {
        switch sort {
        case .date:
            return transactions.sorted { $0.transactionDate > $1.transactionDate }
        case .amount:
            return transactions.sorted { $0.amount > $1.amount }
        }
    }
}
