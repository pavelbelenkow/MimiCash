import Foundation

protocol BackupStorage: AnyObject {
    func addBackupOperation(_ operation: BackupOperation) async
    func update(_ operation: BackupOperation) async
    func removeBackupOperation(id: String) async
    func removeBackupOperations(entityId: Int, entityType: EntityType) async
    func getBackupOperation(id: String) async -> BackupOperation?
    func getBackupOperations(entityId: Int, entityType: EntityType) async -> [BackupOperation]
    var backupOperations: [BackupOperation] { get async }
    func clear() async
} 