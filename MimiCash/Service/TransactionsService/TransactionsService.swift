import Foundation

// MARK: - TransactionsService Protocol

protocol TransactionsService {
    /// Возвращает список транзакций по `id` счета за период от `startDate` до `endDate`
    func fetchTransactions(
        accountId: Int,
        from startDate: Date,
        to endDate: Date
    ) async -> [Transaction]
    
    func post(transaction: Transaction) async throws -> Transaction
    
    func update(transaction: Transaction) async throws -> Transaction
    
    /// Удаляет транзакцию на основании переданного `id` транзакции
    func delete(transactionId: Int) async throws
}

final class TransactionsServiceImp: TransactionsService {
    
    // MARK: - Private Properties
    private let networkClient: NetworkClient
    private let storage: TransactionsStorage
    private let categoriesStorage: CategoriesStorage
    private let bankAccountsStorage: BankAccountsStorage
    private let backupStorage: BackupStorage
    private let syncStatusManager: SyncStatusManager
    private let serviceCoordinator: ServiceCoordinator?
    
    // MARK: - Init
    init(
        networkClient: NetworkClient = NetworkClientImpl(),
        storage: TransactionsStorage,
        categoriesStorage: CategoriesStorage,
        bankAccountsStorage: BankAccountsStorage,
        backupStorage: BackupStorage,
        syncStatusManager: SyncStatusManager = SyncStatusManager.shared,
        serviceCoordinator: ServiceCoordinator? = nil
    ) {
        self.networkClient = networkClient
        self.storage = storage
        self.categoriesStorage = categoriesStorage
        self.bankAccountsStorage = bankAccountsStorage
        self.backupStorage = backupStorage
        self.syncStatusManager = syncStatusManager
        self.serviceCoordinator = serviceCoordinator
    }
    
    func fetchTransactions(
        accountId: Int,
        from startDate: Date,
        to endDate: Date
    ) async -> [Transaction] {
        let syncedOperationIds = await syncAllBackupOperations()
        let backupOperations = await backupStorage.backupOperations
        syncStatusManager.updateUnsyncedCount(backupOperations.count)
        
        do {
            let serverTransactions = try await fetchFromServer(
                accountId: accountId,
                from: startDate,
                to: endDate
            )
            
            await saveTransactionsToStorage(serverTransactions)
            return serverTransactions.sorted { $0.transactionDate > $1.transactionDate }
            
        } catch {
            let localTransactions = await getTransactionsFromLocalStorage(
                accountId: accountId,
                from: startDate,
                to: endDate
            )
            
            let unsyncedTransactions = await getUnsyncedTransactionsFromBackup(
                accountId: accountId,
                from: startDate,
                to: endDate
            )
            
            var allTransactions = localTransactions
            
            for unsyncedTransaction in unsyncedTransactions {
                if !allTransactions.contains(where: { $0.id == unsyncedTransaction.id }) {
                    allTransactions.append(unsyncedTransaction)
                }
            }
            
            return allTransactions.sorted { $0.transactionDate > $1.transactionDate }
        }
    }
    
    func post(transaction: Transaction) async throws -> Transaction {
        do {
            let transactionData = transaction.toTransactionRequest()
            let serverTransactionId = try await postTransactionRequest(transactionData)
            let serverTransaction = await createTransactionFromRequest(transactionData, serverId: serverTransactionId)
            
            await storage.create(serverTransaction)
            await serviceCoordinator?.transactionCreated(serverTransaction)
            return serverTransaction
            
        } catch {
            let localId = await generateUniqueLocalId()
            let localTransaction = Transaction(
                id: localId,
                account: transaction.account,
                category: transaction.category,
                amount: transaction.amount,
                transactionDate: transaction.transactionDate,
                comment: transaction.comment
            )
            
            await storage.create(localTransaction)
            
            let transactionData = localTransaction.toTransactionRequest()
            let backupOperation = BackupOperation(
                entityId: localId,
                entityType: .transaction,
                operationType: .create,
                transactionData: transactionData,
                accountData: nil
            )
            
            await backupStorage.addBackupOperation(backupOperation)
            await serviceCoordinator?.transactionCreated(localTransaction)
            return localTransaction
        }
    }
    
    func update(transaction: Transaction) async throws -> Transaction {
        do {
            let transactionData = transaction.toTransactionRequest()
            let serverTransaction = try await updateTransactionRequest(transactionId: transaction.id, body: transactionData)
            
            await storage.update(serverTransaction)
            await backupStorage.removeBackupOperations(entityId: transaction.id, entityType: .transaction)
            return serverTransaction
            
        } catch {
            await storage.update(transaction)
            
            let transactionData = transaction.toTransactionRequest()
            let backupOperation = BackupOperation(
                entityId: transaction.id,
                entityType: .transaction,
                operationType: .update,
                transactionData: transactionData,
                accountData: nil
            )
            
            await backupStorage.addBackupOperation(backupOperation)
            return transaction
        }
    }
    
    func delete(transactionId: Int) async throws {
        let localTransactions = await storage.transactions
        guard let transaction = localTransactions.first(where: { $0.id == transactionId }) else {
            throw NetworkError.notFound
        }
        
        let accountId = transaction.account.id
        
        do {
            try await deleteFromServer(transactionId)
            await storage.delete(id: transactionId)
            await backupStorage.removeBackupOperations(entityId: transactionId, entityType: .transaction)
            await serviceCoordinator?.transactionDeleted(transactionId: transactionId, accountId: accountId)
            
        } catch {
            await storage.delete(id: transactionId)
            
            let backupOperation = BackupOperation(
                entityId: transactionId,
                entityType: .transaction,
                operationType: .delete,
                transactionData: nil,
                accountData: nil
            )
            
            await backupStorage.addBackupOperation(backupOperation)
            await serviceCoordinator?.transactionDeleted(transactionId: transactionId, accountId: accountId)
        }
    }
}

// MARK: - Private Extensions

private extension TransactionsServiceImp {
    
    func generateUniqueLocalId() async -> Int {
        let existingIds = Set(await storage.transactions.map { $0.id })
        var newId: Int
        
        repeat {
            newId = -Int.random(in: 1...Int.max)
        } while existingIds.contains(newId)
        
        return newId
    }
    
    func syncAllBackupOperations() async -> [String] {
        let backupOperations = await backupStorage.backupOperations
        
        guard !backupOperations.isEmpty else { return [] }
        
        syncStatusManager.updateStatus(.syncing)
        syncStatusManager.updateProgress(SyncProgress(
            totalOperations: backupOperations.count,
            completedOperations: 0,
            currentOperation: "Подготовка синхронизации..."
        ))
        
        var syncedOperationIds: [String] = []
        
        for (index, operation) in backupOperations.enumerated() {
            syncStatusManager.updateProgress(SyncProgress(
                totalOperations: backupOperations.count,
                completedOperations: index,
                currentOperation: "Синхронизация операции \(operation.entityId)..."
            ))
            
            do {
                switch operation.operationType {
                case .create:
                    if let transactionData = operation.transactionData {
                        let serverTransactionId = try await postTransactionRequest(transactionData)
                        
                        await replaceLocalTransaction(
                            localId: operation.entityId,
                            serverId: serverTransactionId,
                            transactionData: transactionData
                        )
                        syncedOperationIds.append(operation.id)
                    }
                    
                case .update:
                    if let transactionData = operation.transactionData, operation.entityId > 0 {
                        let serverTransaction = try await updateTransactionRequest(transactionId: operation.entityId, body: transactionData)
                        await storage.update(serverTransaction)
                        syncedOperationIds.append(operation.id)
                    }
                case .delete:
                    if operation.entityId > 0 {
                        try await deleteFromServer(operation.entityId)
                        await storage.delete(id: operation.entityId)
                        syncedOperationIds.append(operation.id)
                    }
                }
                
            } catch {
                if let networkError = error as? NetworkError {
                    switch networkError {
                    case .conflict:
                        let conflictInfo = ConflictInfo(
                            entityId: operation.entityId,
                            entityType: operation.entityType.rawValue,
                            localVersion: "local",
                            serverVersion: "server",
                            message: "Конфликт при синхронизации \(operation.entityType.rawValue) \(operation.entityId)"
                        )
                        syncStatusManager.updateStatus(.conflict(conflictInfo))
                        print("[TransactionsServiceImp] Conflict detected during sync: \(conflictInfo)")
                        return syncedOperationIds
                    default:
                        break
                    }
                }
            }
        }
        
        syncStatusManager.updateProgress(SyncProgress(
            totalOperations: backupOperations.count,
            completedOperations: backupOperations.count,
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
        
        return syncedOperationIds
    }
    
    func replaceLocalTransaction(
        localId: Int,
        serverId: Int,
        transactionData: TransactionRequestBody
    ) async {
        await storage.delete(id: localId)
        
        let serverTransaction = await createTransactionFromRequest(transactionData, serverId: serverId)
        await storage.create(serverTransaction)
    }
    
    func createTransactionFromRequest(_ body: TransactionRequestBody, serverId: Int) async -> Transaction {
        let transactionDate = ISO8601DateFormatter().date(from: body.transactionDate) ?? Date()
        
        let account = await bankAccountsStorage.getCurrentAccount()
        let category = await categoriesStorage.get(id: body.categoryId)
        
        let finalAccount = account ?? BankAccount(
            id: body.accountId,
            name: "Account \(body.accountId)",
            balance: 0,
            currency: "RUB"
        )
        
        let finalCategory = category ?? Category(
            id: body.categoryId,
            name: "Category \(body.categoryId)",
            emoji: "💰",
            isIncome: .outcome
        )
        
        let transaction = Transaction(
            id: serverId,
            account: finalAccount,
            category: finalCategory,
            amount: Decimal(string: body.amount) ?? 0,
            transactionDate: transactionDate,
            comment: body.comment
        )
        
        return transaction
    }
    
    func getUnsyncedTransactionsFromBackup(
        accountId: Int,
        from startDate: Date,
        to endDate: Date
    ) async -> [Transaction] {
        let backupOperations = await backupStorage.backupOperations
        var unsyncedTransactions: [Transaction] = []
        
        for operation in backupOperations {
            guard operation.entityType == .transaction,
                  operation.operationType == .create,
                  let transactionData = operation.transactionData else {
                continue
            }
            
            if transactionData.accountId == accountId {
                let transactionDate = ISO8601DateFormatter().date(from: transactionData.transactionDate) ?? Date()
                
                if transactionDate >= startDate && transactionDate <= endDate {
                    let localTransactions = await storage.transactions
                    if let localTransaction = localTransactions.first(where: { $0.id == operation.entityId }) {
                        unsyncedTransactions.append(localTransaction)
                    }
                }
            }
        }
        
        return unsyncedTransactions
    }
    
    func fetchFromServer(
        accountId: Int,
        from startDate: Date?,
        to endDate: Date?
    ) async throws -> [Transaction] {
        let request = GetTransactionsRequest(
            accountId: accountId,
            startDate: startDate,
            endDate: endDate
        )
        
        let response = try await networkClient.execute(
            request,
            responseType: [TransactionResponse].self
        )
        
        return response.map { $0.toTransaction() }
    }
    
    func postTransactionRequest(_ body: TransactionRequestBody) async throws -> Int {
        let request = CreateTransactionRequest(body: body)
        
        let response = try await networkClient.execute(
            request,
            responseType: TransactionCreateResponse.self
        )
        
        return response.id
    }
    
    func updateTransactionRequest(transactionId: Int, body: TransactionRequestBody, ) async throws -> Transaction {
        let request = UpdateTransactionRequest(
            transactionId: transactionId,
            body: body
        )
        
        let response = try await networkClient.execute(
            request,
            responseType: TransactionResponse.self
        )
        
        return response.toTransaction()
    }
    
    func deleteFromServer(_ transactionId: Int) async throws {
        let request = DeleteTransactionRequest(transactionId: transactionId)
        
        _ = try await networkClient.execute(
            request,
            responseType: EmptyResponse.self
        )
    }
    
    func saveTransactionsToStorage(_ transactions: [Transaction]) async {
        let existingTransactions = await storage.transactions
        
        for transaction in transactions {
            
            if let _ = existingTransactions.first(where: { $0.id == transaction.id }) {
                await storage.update(transaction)
            } else {
                await storage.create(transaction)
            }
        }
    }
    
    func getTransactionsFromLocalStorage(
        accountId: Int,
        from startDate: Date,
        to endDate: Date
    ) async -> [Transaction] {
        let allTransactions = await storage.transactions
        
        let accountTransactions = allTransactions.filter { $0.account.id == accountId }
        
        let filtered = accountTransactions.filter { transaction in
            transaction.transactionDate >= startDate && transaction.transactionDate <= endDate
        }
        
        return filtered
    }
}

private struct EmptyResponse: Codable {}
