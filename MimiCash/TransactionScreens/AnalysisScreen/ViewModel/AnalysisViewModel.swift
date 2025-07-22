import Foundation
import Combine

// MARK: - AnalysisViewModel Protocol

protocol AnalysisViewModel: TransactionsViewModel, TransactionsSortable, DateRangeSelectable {
    var stateSubject: CurrentValueSubject<ViewState<TransactionsOutput>, Never> { get }
    var sortSubject: CurrentValueSubject<TransactionsSort, Never> { get }
    var sectionsCount: Int { get }
    var cancellables: Set<AnyCancellable> { get set }
    
    func numberOfRowsInSection(_ section: Int) -> Int
    func cellType(for indexPath: IndexPath) -> AnalysisCellType
    func handleDateSelection(type: DateSelectionType, date: Date)
}

final class AnalysisViewModelImp: ObservableObject, AnalysisViewModel, TransactionsProvider, BankAccountsProvider {
    
    // MARK: - TransactionsProvider Properties
    let transactionsService: TransactionsService
    
    // MARK: - BankAccountsProvider Properties
    let bankAccountsService: BankAccountsService
    
    // MARK: - TransactionsViewModel Properties
    let direction: Direction
    var state: ViewState<TransactionsOutput> {
        get { stateSubject.value }
        set { stateSubject.send(newValue) }
    }
    var title: String { "Анализ" }
    
    // MARK: - TransactionsSortable Properties
    var sort: TransactionsSort {
        get { sortSubject.value }
        set { sortSubject.send(newValue) }
    }
    
    // MARK: - DateRangeSelectable Properties
    var startDate: Date = .monthAgo
    var endDate: Date = .endOfToday
    
    // MARK: - AnalysisViewModel Properties
    let sectionsCount: Int = 2
    let stateSubject = CurrentValueSubject<ViewState<TransactionsOutput>, Never>(.idle)
    let sortSubject = CurrentValueSubject<TransactionsSort, Never>(.date)
    var cancellables = Set<AnyCancellable>()
    
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
    
    // MARK: - Deinit
    deinit {
        cancellables.forEach { $0.cancel() }
    }
    
    // MARK: - TransactionsViewModel Methods
    func loadTransactions(
        from startDate: Date,
        to endDate: Date
    ) async {
        state = .loading
        
        do {
            let account = try await fetchCurrentAccount()
            let output = try await fetchTransactions(
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
