import Foundation

// MARK: - TransactionsService Protocol

protocol TransactionsService {
    /// Возвращает список транзакций по `id` счета за период от `startDate` до `endDate`
    func fetchTransactions(
        accountId: Int,
        from startDate: Date,
        to endDate: Date
    ) async throws -> [Transaction]
    
    func post(transaction: Transaction) async throws -> Transaction
    
    func update(transaction: Transaction) async throws -> Transaction
    
    /// Удаляет транзакцию на основании переданного `id` транзакции
    func delete(transactionId: Int) async throws
}

final class TransactionsServiceImp: TransactionsService {
    
    // MARK: - Private Properties
    private let networkAwareService: NetworkAwareService
    private let networkClient: NetworkClient
    private let storage: TransactionsStorage
    private let categoriesStorage: CategoriesStorage
    private let bankAccountsStorage: BankAccountsStorage
    private let backupStorage: BackupStorage
    private let serviceCoordinator: ServiceCoordinator?
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    
    // MARK: - Init
    init(
        networkAwareService: NetworkAwareService = NetworkAwareServiceImpl(),
        networkClient: NetworkClient = NetworkClientImpl(),
        storage: TransactionsStorage,
        categoriesStorage: CategoriesStorage,
        bankAccountsStorage: BankAccountsStorage,
        backupStorage: BackupStorage,
        serviceCoordinator: ServiceCoordinator? = nil
    ) {
        self.networkAwareService = networkAwareService
        self.networkClient = networkClient
        self.storage = storage
        self.categoriesStorage = categoriesStorage
        self.bankAccountsStorage = bankAccountsStorage
        self.backupStorage = backupStorage
        self.serviceCoordinator = serviceCoordinator
    }
    
    func fetchTransactions(
        accountId: Int,
        from startDate: Date,
        to endDate: Date
    ) async throws -> [Transaction] {
        await syncBackupOperations()
        
        return try await networkAwareService.executeWithFallback(
            networkOperation: {
                let serverTransactions = try await fetchFromServer(
                    accountId: accountId,
                    from: startDate,
                    to: endDate
                )
                
                await saveTransactionsToStorage(serverTransactions)
                
                for transaction in serverTransactions {
                    await backupStorage.removeBackupOperations(
                        entityId: transaction.id,
                        entityType: .transaction
                    )
                }
                
                return serverTransactions.sorted { $0.transactionDate > $1.transactionDate }
            },
            fallbackOperation: {
                let localTransactions = await self.getTransactionsFromLocalStorage(
                    accountId: accountId,
                    from: startDate,
                    to: endDate
                )
                let backupOps = await backupStorage
                    .backupOperations
                    .filter { $0.entityType == .transaction }
                
                return merge(local: localTransactions)
            }
        )
    }
    
    func post(transaction: Transaction) async throws -> Transaction {
        return try await networkAwareService.executeWithFallback(
            networkOperation: {
                let transactionData = transaction.toTransactionRequest()
                let serverTransactionId = try await postTransactionRequest(transactionData)
                let serverTransaction = await createTransactionFromRequest(
                    transactionData,
                    serverId: serverTransactionId
                )
                
                await storage.create(serverTransaction)
                await backupStorage.removeBackupOperations(
                    entityId: serverTransaction.id,
                    entityType: .transaction
                )
                
                return serverTransaction
            },
            fallbackOperation: {
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
                let payload = try? encoder.encode(transactionData)
                let backupOperation = BackupOperation(
                    entityId: localTransaction.id,
                    entityType: .transaction,
                    operationType: .create,
                    payload: payload,
                    timestamp: Date()
                )
                
                await backupStorage.addBackupOperation(backupOperation)
                await serviceCoordinator?.transactionCreated(localTransaction)
                
                return localTransaction
            }
        )
    }
    
    func update(transaction: Transaction) async throws -> Transaction {
        return try await networkAwareService.executeWithFallback(
            networkOperation: {
                let transactionData = transaction.toTransactionRequest()
                let serverTransaction = try await updateTransactionRequest(
                    transactionId: transaction.id,
                    body: transactionData
                )
                
                await storage.update(serverTransaction)
                await backupStorage.removeBackupOperations(
                    entityId: serverTransaction.id,
                    entityType: .transaction
                )
                
                return serverTransaction
            },
            fallbackOperation: {
                let oldTransaction = (await storage.transactions)
                    .first(where: { $0.id == transaction.id })
                await storage.update(transaction)
                
                let transactionData = transaction.toTransactionRequest()
                let payload = try? encoder.encode(transactionData)
                let backupOperation = BackupOperation(
                    entityId: transaction.id,
                    entityType: .transaction,
                    operationType: .update,
                    payload: payload,
                    timestamp: Date()
                )
                
                await backupStorage.addBackupOperation(backupOperation)
                
                if let old = oldTransaction {
                    await serviceCoordinator?.transactionUpdated(
                        old: old,
                        new: transaction
                    )
                }
                
                return transaction
            }
        )
    }
    
    func delete(transactionId: Int) async throws {
        let localTransactions = await storage.transactions
        
        guard let transaction = localTransactions.first(where: { $0.id == transactionId }) else {
            throw NetworkError.notFound
        }
        
        return try await networkAwareService.executeWithFallback(
            networkOperation: {
                try await deleteFromServer(transactionId)
                await storage.delete(id: transactionId)
                await backupStorage.removeBackupOperations(
                    entityId: transactionId,
                    entityType: .transaction
                )
            },
            fallbackOperation: {
                await storage.delete(id: transactionId)
                
                let transactionData = transaction.toTransactionRequest()
                let payload = try? encoder.encode(transactionData)
                let backupOperation = BackupOperation(
                    entityId: transaction.id,
                    entityType: .transaction,
                    operationType: .delete,
                    payload: payload,
                    timestamp: Date()
                )
                
                await backupStorage.addBackupOperation(backupOperation)
                await serviceCoordinator?.transactionDeleted(transaction)
            }
        )
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
        
        let allTransactions = await storage.transactions
        let temporaryTransactions = allTransactions.filter { $0.id < 0 }
        
        for transaction in temporaryTransactions {
            
            if transactions.contains(where: {
                $0.account.id == transaction.account.id &&
                $0.amount == transaction.amount &&
                $0.transactionDate == transaction.transactionDate &&
                $0.category.id == transaction.category.id
            }) {
                await storage.delete(id: transaction.id)
            }
        }
        
        var unique = [String: Transaction]()
        for transaction in await storage.transactions {
            let key = "\(transaction.account.id)-\(transaction.amount)-\(transaction.transactionDate.timeIntervalSince1970)-\(transaction.category.id)"
            
            if let existing = unique[key] {
                
                if transaction.id < existing.id {
                    await storage.delete(id: existing.id)
                    unique[key] = transaction
                } else {
                    await storage.delete(id: transaction.id)
                }
                
            } else {
                unique[key] = transaction
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
    
    func syncBackupOperations() async {
        let backupOperations = await backupStorage.backupOperations
        
        for operation in backupOperations where operation.entityType == .transaction {
            
            do {
                if let data = operation.payload {
                    let body = try decoder.decode(TransactionRequestBody.self, from: data)
                    switch operation.operationType {
                    case .create:
                        let request = CreateTransactionRequest(body: body)
                        _ = try await networkClient.execute(
                            request,
                            responseType: TransactionCreateResponse.self
                        )
                    case .update:
                        let request = UpdateTransactionRequest(
                            transactionId: operation.entityId,
                            body: body
                        )
                        _ = try await networkClient.execute(
                            request,
                            responseType: TransactionResponse.self
                        )
                    case .delete:
                        let request = DeleteTransactionRequest(transactionId: operation.entityId)
                        _ = try await networkClient.execute(
                            request,
                            responseType: EmptyResponse.self
                        )
                    }
                }
                print("[Sync] [SUCCESS] Synced and removed backup operation: \(operation.id) for transactionId: \(operation.entityId)")
                
                await backupStorage.removeBackupOperation(id: operation.id)
            } catch {
                print("[Sync] [FAIL] Failed to sync backup operation: \(operation.id), transactionId: \(operation.entityId), error: \(error)")
                
                continue
            }
        }
    }

    func merge(local: [Transaction]) -> [Transaction] {
        local.sorted { $0.transactionDate > $1.transactionDate }
    }
}

private struct EmptyResponse: Codable {}
