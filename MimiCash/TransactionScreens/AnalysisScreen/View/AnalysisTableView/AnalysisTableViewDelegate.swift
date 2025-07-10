import Foundation

// MARK: - AnalysisTableViewDelegate Protocol

protocol AnalysisTableViewDelegate: AnyObject {
    func handleDateSelection(type: DateSelectionType, date: Date)
    func handleSortSelection(_ sort: TransactionsSort)
}
