import Foundation

enum EntityType: String, Codable {
    case transaction
    case account
}

enum OperationType: String, Codable {
    case create
    case update
    case delete
}

struct BackupOperation: Identifiable, Codable {
    let id: String
    let entityId: Int
    let entityType: EntityType
    let operationType: OperationType
    let payload: Data?
    let timestamp: Date
    
    init(
        id: String = UUID().uuidString,
        entityId: Int,
        entityType: EntityType,
        operationType: OperationType,
        payload: Data?,
        timestamp: Date = Date()
    ) {
        self.id = id
        self.entityId = entityId
        self.entityType = entityType
        self.operationType = operationType
        self.payload = payload
        self.timestamp = timestamp
    }
}
