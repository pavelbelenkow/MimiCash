import Foundation

// MARK: - TransactionsHistoryViewModel Protocol

protocol TransactionsHistoryViewModel: TransactionsViewModel, TransactionsSortable, DateRangeSelectable {
    var isAnalysisPresented: Bool { get set }
    
    func presentAnalysis()
}

@Observable
final class TransactionsHistoryViewModelImp: TransactionsHistoryViewModel, TransactionsProvider, BankAccountsProvider {
    
    // MARK: - TransactionsProvider Properties
    let transactionsService: TransactionsService
    
    // MARK: - BankAccountsProvider Properties
    let bankAccountsService: BankAccountsService
    
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
        transactionsService: TransactionsService = ServiceFactory.shared.createTransactionsService(),
        bankAccountsService: BankAccountsService = ServiceFactory.shared.createBankAccountsService(),
        direction: Direction,
        state: ViewState<TransactionsOutput> = .idle
    ) {
        self.transactionsService = transactionsService
        self.bankAccountsService = bankAccountsService
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
            let account = try await fetchCurrentAccount()
            let output = await fetchTransactions(
                accountId: account.id, 
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
