import Foundation

// MARK: - BankAccountsService Protocol

protocol BankAccountsService {
    /// Возвращает первый банковский счет из списка
    func fetchCurrentAccount() async throws -> BankAccount
    
    /// Возвращает обновленный счет, переданный в аргумент `BankAccount`
    func update(account: BankAccount) async throws -> BankAccount
    
    func applyLocalTransactionCreated(_ transaction: Transaction) async throws -> BankAccount
    func applyLocalTransactionUpdated(old oldTransaction: Transaction, new newTransaction: Transaction) async throws -> BankAccount
    func applyLocalTransactionDeleted(_ transaction: Transaction) async throws -> BankAccount
}

final class BankAccountsServiceImp: BankAccountsService {
    
    // MARK: - Private Properties
    private let networkAwareService: NetworkAwareService
    private let networkClient: NetworkClient
    private let storage: BankAccountsStorage
    private let backupStorage: BackupStorage
    private let decoder: JSONDecoder = JSONDecoder()
    private let encoder: JSONEncoder = JSONEncoder()
    
    // MARK: - Init
    init(
        networkAwareService: NetworkAwareService = NetworkAwareServiceImpl(),
        networkClient: NetworkClient = NetworkClientImpl(),
        storage: BankAccountsStorage,
        backupStorage: BackupStorage
    ) {
        self.networkAwareService = networkAwareService
        self.networkClient = networkClient
        self.storage = storage
        self.backupStorage = backupStorage
    }

    func fetchCurrentAccount() async throws -> BankAccount {
        await syncBackupOperations()
        
        return try await networkAwareService.executeWithFallback(
            networkOperation: {
                let serverAccount = try await fetchFromServer()
                
                await saveAccountToStorage(serverAccount)
                await backupStorage.removeBackupOperations(
                    entityId: serverAccount.id,
                    entityType: .account
                )
                
                return serverAccount
            },
            fallbackOperation: {
                guard let localAccount = await storage.getCurrentAccount() else {
                    throw NetworkError.notFound
                }
                return localAccount
            }
        )
    }
    
    func update(account: BankAccount) async throws -> BankAccount {
        return try await networkAwareService.executeWithFallback(
            networkOperation: {
                let body = account.toAccountUpdateBody()
                let serverAccount = try await updateAccountRequest(body, accountId: account.id)
                
                await storage.update(serverAccount)
                await backupStorage.removeBackupOperations(
                    entityId: serverAccount.id,
                    entityType: .account
                )
                
                return serverAccount
            },
            fallbackOperation: {
                await storage.update(account)
                
                let body = account.toAccountUpdateBody()
                let payload = try? encoder.encode(body)
                let backupOp = BackupOperation(
                    entityId: account.id,
                    entityType: .account,
                    operationType: .update,
                    payload: payload,
                    timestamp: Date()
                )
                
                await backupStorage.addBackupOperation(backupOp)
                
                return account
            }
        )
    }
}

private extension BankAccountsServiceImp {
    
    func saveAccountToStorage(_ account: BankAccount) async {
        let existingAccounts = await storage.accounts
        let exists = existingAccounts.contains { $0.id == account.id }
        
        if exists {
            await storage.update(account)
        } else {
            await storage.create(account)
        }
    }
    
    func fetchFromServer() async throws -> BankAccount {
        let request = GetAccountsRequest()
        
        let response = try await networkClient.execute(
            request,
            responseType: [AccountResponse].self
        )
        
        let accounts = response.map { $0.toBankAccount() }
        
        guard let firstAccount = accounts.first else {
            throw NetworkError.notFound
        }
        
        return firstAccount
    }
    
    func updateOnServer(_ account: BankAccount) async throws -> BankAccount {
        let request = UpdateAccountRequest(
            accountId: account.id,
            body: account.toAccountUpdateBody()
        )
        
        let response = try await networkClient.execute(
            request,
            responseType: AccountResponse.self
        )
        
        return response.toBankAccount()
    }
    
    func updateAccountRequest(_ body: AccountUpdateBody, accountId: Int) async throws -> BankAccount {
        let request = UpdateAccountRequest(
            accountId: accountId,
            body: body
        )
        
        let response = try await networkClient.execute(
            request,
            responseType: AccountResponse.self
        )
        
        return response.toBankAccount()
    }

    func syncBackupOperations() async {
        let backupOperations = await backupStorage.backupOperations
        
        for operation in backupOperations where operation.entityType == .account {
            
            do {
                if let data = operation.payload {
                    let body = try decoder.decode(AccountUpdateBody.self, from: data)
                    
                    switch operation.operationType {
                    case .update:
                        let request = UpdateAccountRequest(
                            accountId: operation.entityId,
                            body: body
                        )
                        _ = try await networkClient.execute(
                            request,
                            responseType: AccountResponse.self
                        )
                    default: break
                    }
                }
                print("Synced and removed backup operation: \(operation.id) for accountId: \(operation.entityId)")
                
                await backupStorage.removeBackupOperation(id: operation.id)
            } catch {
                print("[FAIL] Failed to sync backup operation: \(operation.id), accountId: \(operation.entityId), error: \(error)")
                
                continue
            }
        }
    }
}

extension BankAccountsServiceImp {
    
    func applyLocalTransactionCreated(_ transaction: Transaction) async throws -> BankAccount {
        guard var account = await storage.getCurrentAccount() else {
            throw NetworkError.notFound
        }
        
        switch transaction.category.isIncome {
        case .income:
            account = BankAccount(
                id: account.id,
                name: account.name,
                balance: account.balance + transaction.amount,
                currency: account.currency
            )
        case .outcome:
            account = BankAccount(
                id: account.id,
                name: account.name,
                balance: account.balance - transaction.amount,
                currency: account.currency
            )
        }
        
        await storage.update(account)
        return account
    }

    func applyLocalTransactionUpdated(
        old oldTransaction: Transaction,
        new newTransaction: Transaction
    ) async throws -> BankAccount {
        guard var account = await storage.getCurrentAccount() else {
            throw NetworkError.notFound
        }
        
        switch oldTransaction.category.isIncome {
        case .income:
            account = BankAccount(
                id: account.id,
                name: account.name,
                balance: account.balance - oldTransaction.amount,
                currency: account.currency
            )
        case .outcome:
            account = BankAccount(
                id: account.id,
                name: account.name,
                balance: account.balance + oldTransaction.amount,
                currency: account.currency
            )
        }
        
        switch newTransaction.category.isIncome {
        case .income:
            account = BankAccount(
                id: account.id,
                name: account.name,
                balance: account.balance + newTransaction.amount,
                currency: account.currency
            )
        case .outcome:
            account = BankAccount(
                id: account.id,
                name: account.name,
                balance: account.balance - newTransaction.amount,
                currency: account.currency
            )
        }
        
        await storage.update(account)
        return account
    }
    
    func applyLocalTransactionDeleted(_ transaction: Transaction) async throws -> BankAccount {
        guard var account = await storage.getCurrentAccount() else {
            throw NetworkError.notFound
        }
        
        switch transaction.category.isIncome {
        case .income:
            account = BankAccount(
                id: account.id,
                name: account.name,
                balance: account.balance - transaction.amount,
                currency: account.currency
            )
        case .outcome:
            account = BankAccount(
                id: account.id,
                name: account.name,
                balance: account.balance + transaction.amount,
                currency: account.currency
            )
        }
        
        await storage.update(account)
        return account
    }
}
