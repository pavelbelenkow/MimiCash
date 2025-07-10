import Foundation

// MARK: - DateRangeSelectable Protocol

protocol DateRangeSelectable: AnyObject {
    var startDate: Date { get set }
    var endDate: Date { get set }
    
    func updateStartDate(_ date: Date)
    func updateEndDate(_ date: Date)
    func validateAndReloadData()
}

// MARK: - Default Implementation

extension DateRangeSelectable {
    
    func updateStartDate(_ newStart: Date) {
        startDate = newStart.dayStart
        
        if startDate > endDate {
            endDate = newStart.dayEnd
        }
        
        validateAndReloadData()
    }
    
    func updateEndDate(_ newEnd: Date) {
        endDate = newEnd.dayEnd
        
        if endDate < startDate {
            startDate = newEnd.dayStart
        }
        
        validateAndReloadData()
    }
} 

// MARK: - DateRangeSelectable + TransactionsViewModel

extension DateRangeSelectable where Self: TransactionsViewModel {
    
    func validateAndReloadData() {
        Task {
            await loadTransactions(from: startDate, to: endDate)
        }
    }
}
