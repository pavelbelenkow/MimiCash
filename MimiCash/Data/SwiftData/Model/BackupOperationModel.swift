import Foundation
import SwiftData

@Model
final class BackupOperationModel {
    var id: String
    var entityId: Int
    var entityType: String
    var operationType: String
    var transactionData: Data?
    var accountData: Data?
    var timestamp: Date
    
    init(from backupOperation: BackupOperation) {
        self.id = backupOperation.id
        self.entityId = backupOperation.entityId
        self.entityType = backupOperation.entityType.rawValue
        self.operationType = backupOperation.operationType.rawValue
        self.timestamp = backupOperation.timestamp
        
        if let transactionData = backupOperation.transactionData {
            self.transactionData = try? JSONEncoder().encode(transactionData)
        }
        
        if let accountData = backupOperation.accountData {
            self.accountData = try? JSONEncoder().encode(accountData)
        }
    }
    
    func toBackupOperation() -> BackupOperation? {
        guard let entityType = EntityType(rawValue: entityType),
              let operationType = OperationType(rawValue: operationType) else {
            print("Invalid entityType or operationType: \(entityType), \(operationType)")
            return nil
        }
        
        var transactionData: TransactionRequestBody?
        if let data = self.transactionData {
            transactionData = try? JSONDecoder().decode(TransactionRequestBody.self, from: data)
        }
        
        var accountData: AccountUpdateBody?
        if let data = self.accountData {
            accountData = try? JSONDecoder().decode(AccountUpdateBody.self, from: data)
        }
        
        return BackupOperation(
            entityId: entityId,
            entityType: entityType,
            operationType: operationType,
            transactionData: transactionData,
            accountData: accountData
        )
    }
} 
