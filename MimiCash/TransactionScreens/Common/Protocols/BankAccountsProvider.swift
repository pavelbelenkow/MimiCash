// MARK: - BankAccountsProvider Protocol

protocol BankAccountsProvider {
    var bankAccountsService: BankAccountsService { get }
    
    func fetchCurrentAccount() async throws -> BankAccount
    func update(account: BankAccount) async throws -> BankAccount
}

extension BankAccountsProvider {
    
    func fetchCurrentAccount() async throws -> BankAccount {
        try await bankAccountsService.fetchCurrentAccount()
    }
    
    func update(account: BankAccount) async throws -> BankAccount {
        try await bankAccountsService.update(account: account)
    }
}
