import Foundation

// MARK: - TransactionsViewModel Protocol

protocol TransactionsViewModel {
    var direction: Direction { get }
    var state: ViewState<TransactionsOutput> { get set }
    var title: String { get }
    
    func loadTransactions(
        from startDate: Date,
        to endDate: Date
    ) async
}
