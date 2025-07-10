import Foundation

// MARK: - TransactionsListViewModel Protocol

protocol TransactionsListViewModel: TransactionsViewModel {
    var isHistoryPresented: Bool { get set }
    var isAddTransactionPresented: Bool { get set }
    
    func presentTransactionHistory()
    func presentAddTransaction()
}

@Observable
final class TransactionsListViewModelImp: TransactionsListViewModel, TransactionsProvider {
    
    // MARK: - TransactionsProvider Properties
    let service: TransactionsService
    
    // MARK: - TransactionsViewModel Properties
    let direction: Direction
    var state: ViewState<TransactionsOutput>
    var title: String {
        (direction == .income ?
        Tab.incomes.label : Tab.outcomes.label) + " cегодня"
    }
    
    // MARK: - TransactionsListViewModel Properties
    var isHistoryPresented: Bool = false
    var isAddTransactionPresented: Bool = false
    
    // MARK: - Init
    init(
        service: TransactionsService = TransactionsServiceImp(),
        direction: Direction,
        state: ViewState<TransactionsOutput> = .idle
    ) {
        self.service = service
        self.direction = direction
        self.state = state
    }
    
    // MARK: - TransactionsViewModel Methods
    func loadTransactions(
        from startDate: Date,
        to endDate: Date
    ) async {
        state = .loading
        
        do {
            let output = try await fetchTransactions(
                accountId: 1, 
                from: startDate, 
                to: endDate, 
                direction: direction
            )
            state = .success(output)
        } catch {
            state = .error(error.localizedDescription)
        }
    }
    
    func presentTransactionHistory() {
        isHistoryPresented = true
    }
    
    func presentAddTransaction() {
        isAddTransactionPresented = true
    }
}
