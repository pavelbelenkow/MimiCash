import Foundation

// MARK: - BankAccountsStorage Protocol

protocol BankAccountsStorage {
    var accounts: [BankAccount] { get async }
    func create(_ account: BankAccount) async
    func update(_ account: BankAccount) async
    func delete(id: Int) async
    func getCurrentAccount() async -> BankAccount?
    func clear() async
}
