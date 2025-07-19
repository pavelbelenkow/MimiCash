import Foundation

// MARK: - ServiceCoordinator

protocol ServiceCoordinator {
    func transactionCreated(_ transaction: Transaction) async
    func transactionUpdated(_ transaction: Transaction) async
    func transactionDeleted(transactionId: Int, accountId: Int) async
}

final class ServiceCoordinatorImp: ServiceCoordinator {
    
    // MARK: - Private Properties
    private let bankAccountsService: BankAccountsService
    private let backupStorage: BackupStorage
    
    // MARK: - Init
    init(
        bankAccountsService: BankAccountsService,
        backupStorage: BackupStorage
    ) {
        self.bankAccountsService = bankAccountsService
        self.backupStorage = backupStorage
    }
    
    // MARK: - ServiceCoordinator Implementation
    
    func transactionCreated(_ transaction: Transaction) async {
        await addAccountUpdateToBackup(account: transaction.account)
    }
    
    func transactionUpdated(_ transaction: Transaction) async {
        await addAccountUpdateToBackup(account: transaction.account)
    }
    
    func transactionDeleted(transactionId: Int, accountId: Int) async {
        do {
            let account = try await bankAccountsService.fetchCurrentAccount()
            if account.id == accountId {
                await addAccountUpdateToBackup(account: account)
            }
        } catch {
            let fallbackAccount = BankAccount(
                id: accountId,
                name: "Account",
                balance: 0,
                currency: "RUB"
            )
            await addAccountUpdateToBackup(account: fallbackAccount)
        }
    }
    
    // MARK: - Private Methods
    
    private func addAccountUpdateToBackup(account: BankAccount) async {
        let accountData = account.toAccountUpdateBody()
        let backupOperation = BackupOperation(
            entityId: account.id,
            entityType: .account,
            operationType: .update,
            transactionData: nil,
            accountData: accountData
        )
        
        let existingOperations = await backupStorage.getBackupOperations(
            entityId: account.id,
            entityType: .account
        )
        
        if existingOperations.isEmpty {
            await backupStorage.addBackupOperation(backupOperation)
        } else {
            if let _ = existingOperations.first {
                let updatedOperation = BackupOperation(
                    entityId: account.id,
                    entityType: .account,
                    operationType: .update,
                    transactionData: nil,
                    accountData: accountData
                )
                await backupStorage.update(updatedOperation)
            }
            
        }
    }
}
