import Foundation

// MARK: - ServiceCoordinator

protocol ServiceCoordinator {
    func transactionCreated(_ transaction: Transaction) async
    func transactionUpdated(old: Transaction, new: Transaction) async
    func transactionDeleted(_ transaction: Transaction) async
}

final class ServiceCoordinatorImp: ServiceCoordinator {
    
    // MARK: - Private Properties
    private let bankAccountsService: BankAccountsService
    
    // MARK: - Init
    init(bankAccountsService: BankAccountsService) {
        self.bankAccountsService = bankAccountsService
    }
    
    // MARK: - ServiceCoordinator Implementation
    
    func transactionCreated(_ transaction: Transaction) async {
        _ = try? await bankAccountsService.applyLocalTransactionCreated(transaction)
    }
    
    func transactionUpdated(
        old oldTransaction: Transaction,
        new newTransaction: Transaction
    ) async {
        _ = try? await bankAccountsService.applyLocalTransactionUpdated(
            old: oldTransaction,
            new: newTransaction
        )
    }
    
    func transactionDeleted(_ transaction: Transaction) async {
        _ = try? await bankAccountsService.applyLocalTransactionDeleted(transaction)
    }
}
