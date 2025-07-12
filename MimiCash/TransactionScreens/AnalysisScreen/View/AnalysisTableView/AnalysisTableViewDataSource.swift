import Foundation

// MARK: - AnalysisTableViewDataSource Protocol

protocol AnalysisTableViewDataSource: AnyObject {
    var sectionsCount: Int { get }
    func numberOfRows(in section: Int) -> Int
    func cellType(for indexPath: IndexPath) -> AnalysisCellType
    func startDate() -> Date
    func endDate() -> Date
    func currentSort() -> TransactionsSort
    func sortedOutput() -> TransactionsOutput?
}
