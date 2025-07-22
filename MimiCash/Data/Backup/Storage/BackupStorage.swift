import Foundation

// MARK: - BackupOperation

struct BackupOperation: Identifiable, Codable {
    let id: String
    let entityId: Int
    let entityType: EntityType
    let operationType: OperationType
    let transactionData: TransactionRequestBody?
    let accountData: AccountUpdateBody?
    let timestamp: Date
    
    init(
        entityId: Int,
        entityType: EntityType,
        operationType: OperationType,
        transactionData: TransactionRequestBody? = nil,
        accountData: AccountUpdateBody? = nil
    ) {
        self.id = UUID().uuidString
        self.entityId = entityId
        self.entityType = entityType
        self.operationType = operationType
        self.transactionData = transactionData
        self.accountData = accountData
        self.timestamp = Date()
    }
}

enum EntityType: String, Codable, CaseIterable {
    case transaction
    case account
}

enum OperationType: String, Codable, CaseIterable {
    case create
    case update
    case delete
}

// MARK: - BackupStorage Protocol

protocol BackupStorage {
    var backupOperations: [BackupOperation] { get async }
    func addBackupOperation(_ operation: BackupOperation) async
    func update(_ operation: BackupOperation) async
    func removeBackupOperation(id: String) async
    func removeBackupOperations(entityId: Int, entityType: EntityType) async
    func getBackupOperation(id: String) async -> BackupOperation?
    func getBackupOperations(entityId: Int, entityType: EntityType) async -> [BackupOperation]
    func clear() async
} 
