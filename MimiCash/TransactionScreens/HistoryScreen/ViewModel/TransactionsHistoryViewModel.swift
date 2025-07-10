import Foundation

// MARK: - TransactionsHistoryViewModel Protocol

protocol TransactionsHistoryViewModel: TransactionsViewModel, TransactionsSortable, DateRangeSelectable {
    var isAnalysisPresented: Bool { get set }
    
    func presentAnalysis()
}

@Observable
final class TransactionsHistoryViewModelImp: TransactionsHistoryViewModel, TransactionsProvider {
    // MARK: - TransactionsProvider Properties
    let service: TransactionsService
    
    // MARK: - TransactionsViewModel Properties
    let direction: Direction
    var state: ViewState<TransactionsOutput>
    var title: String { "Моя история" }
    
    // MARK: - TransactionsSortable Properties
    var sort: TransactionsSort = .date
    
    // MARK: - DateRangeSelectable Properties
    var startDate: Date = .monthAgo
    var endDate: Date = .endOfToday
    
    // MARK: - TransactionsHistoryViewModel Properties
    var isAnalysisPresented: Bool = false
    
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
    
    // MARK: - TransactionsHistoryViewModel Methods
    func presentAnalysis() {
        isAnalysisPresented = true
    }
}
