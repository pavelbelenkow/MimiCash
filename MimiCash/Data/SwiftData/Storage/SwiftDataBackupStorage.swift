import Foundation
import SwiftData

actor SwiftDataBackupStorage: BackupStorage {
    
    // MARK: - Private Properties
    private let modelContext: ModelContext
    
    // MARK: - Init
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    // MARK: - BackupStorage Implementation
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
        let existingOperations = await getBackupOperations(
            entityId: operation.entityId,
            entityType: operation.entityType
        )
        let allOperations = existingOperations + [operation]
        let optimizedOperation = optimizeOperationChain(allOperations)
        
        await removeBackupOperations(entityId: operation.entityId, entityType: operation.entityType)
        
        if let optimized = optimizedOperation {
            let model = BackupOperationModel(from: optimized)
            modelContext.insert(model)
            
            do {
                try modelContext.save()
            } catch {
                print("Error adding optimized backup operation: \(error)")
            }
        }
    }
    
    private func optimizeOperationChain(_ operations: [BackupOperation]) -> BackupOperation? {
        let sortedOperations = operations.sorted { $0.timestamp < $1.timestamp }
        
        if sortedOperations.last?.operationType == .delete {
            return nil
        }
        
        if sortedOperations.count == 1 && sortedOperations.first?.operationType == .create {
            return sortedOperations.first
        }
        
        if sortedOperations.first?.operationType == .create {
            let finalData = sortedOperations.last?.transactionData ?? sortedOperations.first?.transactionData
            
            return BackupOperation(
                entityId: sortedOperations.first!.entityId,
                entityType: sortedOperations.first!.entityType,
                operationType: .create,
                transactionData: finalData,
                accountData: nil
            )
        }
        
        if sortedOperations.allSatisfy({ $0.operationType == .update }) {
            return sortedOperations.last
        }
        
        return nil
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
                model.timestamp = operation.timestamp
                
                if let transactionData = operation.transactionData {
                    model.transactionData = try? JSONEncoder().encode(transactionData)
                } else {
                    model.transactionData = nil
                }
                
                if let accountData = operation.accountData {
                    model.accountData = try? JSONEncoder().encode(accountData)
                } else {
                    model.accountData = nil
                }
                
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
