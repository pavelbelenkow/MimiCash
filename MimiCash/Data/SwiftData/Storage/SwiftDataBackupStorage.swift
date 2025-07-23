import Foundation
import SwiftData

@MainActor
final class SwiftDataBackupStorage: BackupStorage {
    
    // MARK: - Private Properties
    private let modelContext: ModelContext
    
    // MARK: - Init
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    var backupOperations: [BackupOperation] {
        get async {
            let descriptor = FetchDescriptor<BackupOperationModel>(
                sortBy: [SortDescriptor(\.timestamp, order: .forward)]
            )
            
            do {
                let models = try modelContext.fetch(descriptor)
                return models.compactMap { $0.toBackupOperation() }
            } catch {
                print("Error fetching backup operations: \(error)")
                return []
            }
        }
    }
    
    func addBackupOperation(_ operation: BackupOperation) async {
        await removeBackupOperations(
            entityId: operation.entityId,
            entityType: operation.entityType
        )
        
        let model = BackupOperationModel(from: operation)
        modelContext.insert(model)
        
        do {
            try modelContext.save()
        } catch {
            print("Error adding backup operation: \(error)")
        }
    }
    
    func update(_ operation: BackupOperation) async {
        let descriptor = FetchDescriptor<BackupOperationModel>(
            predicate: #Predicate<BackupOperationModel> { $0.id == operation.id }
        )
        
        do {
            let models = try modelContext.fetch(descriptor)
            
            if let model = models.first {
                model.entityId = operation.entityId
                model.entityType = operation.entityType.rawValue
                model.operationType = operation.operationType.rawValue
                model.payload = operation.payload
                model.timestamp = operation.timestamp
                try modelContext.save()
            } else {
                await addBackupOperation(operation)
            }
        } catch {
            print("Error updating backup operation: \(error)")
        }
    }
    
    func removeBackupOperation(id: String) async {
        let descriptor = FetchDescriptor<BackupOperationModel>(
            predicate: #Predicate<BackupOperationModel> { $0.id == id }
        )
        
        do {
            let models = try modelContext.fetch(descriptor)
            
            for model in models {
                modelContext.delete(model)
            }
            
            try modelContext.save()
        } catch {
            print("Error removing backup operation with id \(id): \(error)")
        }
    }
    
    func removeBackupOperations(entityId: Int, entityType: EntityType) async {
        let descriptor = FetchDescriptor<BackupOperationModel>(
            predicate: #Predicate<BackupOperationModel> {
                $0.entityId == entityId && $0.entityType == entityType.rawValue
            }
        )
        
        do {
            let models = try modelContext.fetch(descriptor)
            
            for model in models {
                modelContext.delete(model)
            }
            
            try modelContext.save()
        } catch {
            print("Error removing backup operations for entity \(entityId) of type \(entityType): \(error)")
        }
    }
    
    func getBackupOperation(id: String) async -> BackupOperation? {
        let descriptor = FetchDescriptor<BackupOperationModel>(
            predicate: #Predicate<BackupOperationModel> { $0.id == id }
        )
        
        do {
            let models = try modelContext.fetch(descriptor)
            return models.first?.toBackupOperation()
        } catch {
            print("Error getting backup operation with id \(id): \(error)")
            return nil
        }
    }
    
    func getBackupOperations(entityId: Int, entityType: EntityType) async -> [BackupOperation] {
        let descriptor = FetchDescriptor<BackupOperationModel>(
            predicate: #Predicate<BackupOperationModel> {
                $0.entityId == entityId && $0.entityType == entityType.rawValue
            },
            sortBy: [SortDescriptor(\.timestamp, order: .forward)]
        )
        
        do {
            let models = try modelContext.fetch(descriptor)
            return models.compactMap { $0.toBackupOperation() }
        } catch {
            print("Error getting backup operations for entity \(entityId) of type \(entityType): \(error)")
            return []
        }
    }
    
    func clear() async {
        let descriptor = FetchDescriptor<BackupOperationModel>()
        
        do {
            let models = try modelContext.fetch(descriptor)
            
            for model in models {
                modelContext.delete(model)
            }
            
            try modelContext.save()
        } catch {
            print("Error clearing backup operations: \(error)")
        }
    }
}
