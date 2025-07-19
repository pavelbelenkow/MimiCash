import Foundation

// MARK: - TransactionsStorage Protocol

protocol TransactionsStorage {
    var transactions: [Transaction] { get async }
    func create(_ transaction: Transaction) async
    func update(_ transaction: Transaction) async
    func delete(id: Int) async
    func getTransactions(from startDate: Date, to endDate: Date) async -> [Transaction]
    func clear() async
} 
