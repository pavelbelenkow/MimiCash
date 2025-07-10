import Foundation

// MARK: - AnalysisViewModel Protocol

protocol AnalysisViewModel: TransactionsViewModel, TransactionsSortable, DateRangeSelectable {
    var sectionsCount: Int { get }
    
    func numberOfRowsInSection(_ section: Int) -> Int
    func cellType(for indexPath: IndexPath) -> AnalysisCellType
    func handleDateSelection(type: DateSelectionType, date: Date)
}

@Observable
final class AnalysisViewModelImp: AnalysisViewModel, TransactionsProvider {
    
    // MARK: - TransactionsProvider Properties
    let service: TransactionsService
    
    // MARK: - TransactionsViewModel Properties
    let direction: Direction
    var state: ViewState<TransactionsOutput>
    var title: String { "Анализ" }
    
    // MARK: - TransactionsSortable Properties
    var sort: TransactionsSort = .date
    
    // MARK: - DateRangeSelectable Properties
    var startDate: Date = .monthAgo
    var endDate: Date = .endOfToday
    
    // MARK: - AnalysisViewModel Properties
    let sectionsCount: Int = 2
    
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
    
    // MARK: - AnalysisViewModel Methods
    func numberOfRowsInSection(_ section: Int) -> Int {
        switch section {
        case 0:
            return 4
        case 1:
            guard case .success = state else { return 0 }
            let output = sortedOutput
            
            if output?.transactions.isEmpty == true {
                return 1
            } else {
                return output?.transactions.count ?? 0
            }
        default:
            return 0
        }
    }
    
    func cellType(for indexPath: IndexPath) -> AnalysisCellType {
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                return .startDatePicker
            case 1:
                return .endDatePicker
            case 2:
                return .sortPicker
            case 3:
                return .totalAmount
            default:
                return .emptyState
            }
        case 1:
            if let output = sortedOutput, output.transactions.isEmpty {
                return .emptyState
            } else {
                if let output = sortedOutput, indexPath.row < output.transactions.count {
                    let transaction = output.transactions[indexPath.row]
                    return .transaction(transaction)
                } else {
                    return .emptyState
                }
            }
        default:
            return .emptyState
        }
    }
    
    func handleDateSelection(type: DateSelectionType, date: Date) {
        switch type {
        case .start:
            updateStartDate(date)
        case .end:
            updateEndDate(date)
        }
    }
}
