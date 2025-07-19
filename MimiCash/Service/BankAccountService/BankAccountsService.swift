import Foundation

// MARK: - BankAccountsService Protocol

protocol BankAccountsService {
    /// Возвращает первый банковский счет из списка
    func fetchCurrentAccount() async throws -> BankAccount
    
    /// Возвращает обновленный счет, переданный в аргумент `BankAccount`
    func update(account: BankAccount) async throws -> BankAccount
}

final class BankAccountsServiceImp: BankAccountsService {
    
    private let networkClient: NetworkClient
    private let storage: BankAccountsStorage
    private let backupStorage: BackupStorage
    private let syncStatusManager: SyncStatusManager
    
    init(
        networkClient: NetworkClient = NetworkClientImpl(),
        storage: BankAccountsStorage,
        backupStorage: BackupStorage,
        syncStatusManager: SyncStatusManager = SyncStatusManager.shared
    ) {
        self.networkClient = networkClient
        self.storage = storage
        self.backupStorage = backupStorage
        self.syncStatusManager = syncStatusManager
    }

    func fetchCurrentAccount() async throws -> BankAccount {
        await syncAllBackupOperations()
        
        do {
            let serverAccount = try await fetchFromServer()
            await saveAccountToStorage(serverAccount)
            
            return serverAccount
            
        } catch {
            if let localAccount = await storage.getCurrentAccount() {
                return localAccount
            } else {
                throw NetworkError.notFound
            }
        }
    }
    
    func update(account: BankAccount) async throws -> BankAccount {
        do {
            let body = account.toAccountUpdateBody()
            let serverAccount = try await updateAccountRequest(body, accountId: account.id)
            
            await storage.update(serverAccount)
            await backupStorage.removeBackupOperations(entityId: account.id, entityType: .account)
            
            return serverAccount
            
        } catch {
            let accountData = account.toAccountUpdateBody()
            let backupOperation = BackupOperation(
                entityId: account.id,
                entityType: .account,
                operationType: .update,
                transactionData: nil,
                accountData: accountData
            )
            
            await backupStorage.addBackupOperation(backupOperation)
            await storage.update(account)
            
            return account
        }
    }
}

private extension BankAccountsServiceImp {
    
    func syncAllBackupOperations() async {
        let backupOperations = await backupStorage.backupOperations
        
        guard !backupOperations.isEmpty else { return }
        
        syncStatusManager.updateStatus(.syncing)
        syncStatusManager.updateProgress(SyncProgress(
            totalOperations: backupOperations.count,
            completedOperations: 0,
            currentOperation: "Подготовка синхронизации..."
        ))
        
        var syncedOperationIds: [String] = []
        
        let accountOperations = backupOperations.filter { $0.entityType == .account }
        
        for (index, operation) in accountOperations.enumerated() {
            syncStatusManager.updateProgress(SyncProgress(
                totalOperations: accountOperations.count,
                completedOperations: index,
                currentOperation: "Синхронизация операции \(operation.entityId)..."
            ))
            
            do {
                switch operation.operationType {
                case .update:
                    if let accountData = operation.accountData {
                        let serverAccount = try await updateAccountRequest(accountData, accountId: operation.entityId)
                        
                        await storage.update(serverAccount)
                        
                        syncedOperationIds.append(operation.id)
                    }
                    
                default:
                    break
                }
                
            } catch {
                print("Failed to sync backup operation \(operation.id): \(error)")
                
                if let networkError = error as? NetworkError {
                    switch networkError {
                    case .conflict:
                        let conflictInfo = ConflictInfo(
                            entityId: operation.entityId,
                            entityType: operation.entityType.rawValue,
                            localVersion: "local",
                            serverVersion: "server",
                            message: "Конфликт при синхронизации счета \(operation.entityId)"
                        )
                        syncStatusManager.updateStatus(.conflict(conflictInfo))
                        return
                    default:
                        break
                    }
                }
            }
        }
        
        syncStatusManager.updateProgress(SyncProgress(
            totalOperations: accountOperations.count,
            completedOperations: accountOperations.count,
            currentOperation: "Синхронизация завершена"
        ))
        
        for operationId in syncedOperationIds {
            await backupStorage.removeBackupOperation(id: operationId)
        }
        
        let remainingOperations = await backupStorage.backupOperations
        syncStatusManager.updateUnsyncedCount(remainingOperations.count)
        
        if remainingOperations.isEmpty {
            syncStatusManager.updateStatus(.completed)
        } else {
            syncStatusManager.updateStatus(
                .failed(
                    ErrorEquatable(SyncError.unsyncedOperations(remainingOperations.count))
                )
            )
        }
    }
    
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
}
