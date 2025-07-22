import Foundation
import SwiftData

@Model
final class BackupOperationModel {
    var id: String
    var entityId: Int
    var entityType: String
    var operationType: String
    var payload: Data?
    var timestamp: Date
    
    init(from backupOperation: BackupOperation) {
        self.id = backupOperation.id
        self.entityId = backupOperation.entityId
        self.entityType = backupOperation.entityType.rawValue
        self.operationType = backupOperation.operationType.rawValue
        self.payload = backupOperation.payload
        self.timestamp = backupOperation.timestamp
    }
    
    func toBackupOperation() -> BackupOperation? {
        guard let entityType = EntityType(rawValue: entityType),
              let operationType = OperationType(rawValue: operationType) else {
            print("Invalid entityType or operationType: \(entityType), \(operationType)")
            return nil
        }
        return BackupOperation(
            id: id,
            entityId: entityId,
            entityType: entityType,
            operationType: operationType,
            payload: payload,
            timestamp: timestamp
        )
    }
} 
