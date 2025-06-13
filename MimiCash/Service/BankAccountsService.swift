import Foundation

// MARK: - BankAccountsService Protocol

protocol BankAccountsService {
    /// Возвращает первый банковский счет из списка
    func fetchCurrentAccount() async throws -> BankAccount
    
    /// Возвращает обновленный счет, переданный в аргумент `BankAccount`
    func update(account: BankAccount) async throws -> BankAccount
}

final class BankAccountsServiceImp: BankAccountsService {
    
    private var accounts = [
        BankAccount(id: 1, name: "Основной счет", balance: 1000.00, currency: "RUB"),
        BankAccount(id: 2, name: "Счет в евро", balance: 10.00, currency: "EUR")
    ]
    
    func fetchCurrentAccount() async throws -> BankAccount {
        guard let firstAccount = accounts.first else {
            throw NSError(domain: "AccountNotFound", code: 404)
        }
        return firstAccount
    }
    
    func update(account: BankAccount) async throws -> BankAccount {
        guard
            let index = accounts.firstIndex(where: { $0.id == account.id })
        else {
            throw NSError(domain: "AccountNotFound", code: 404)
        }
        
        accounts[index] = account
        return account
    }
}
