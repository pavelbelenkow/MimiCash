import Foundation
import SwiftData

// MARK: - ModelContainer

final class AppModelContainer {
    
    // MARK: - Singleton
    static let shared = AppModelContainer()
    
    // MARK: - Private Properties
    private let modelContainer: ModelContainer
    
    // MARK: - Init
    private init() {
        let schema = Schema([
            TransactionModel.self,
            BankAccountModel.self,
            CategoryModel.self,
            BackupOperationModel.self
        ])
        
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )
        
        do {
            self.modelContainer = try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }
    
    // MARK: - Methods
    
    func modelContext() -> ModelContext {
        return ModelContext(modelContainer)
    }
    
    func getModelContainer() -> ModelContainer {
        return modelContainer
    }
    
    func transactionsStorage() -> TransactionsStorage {
        return SwiftDataTransactionsStorage(modelContext: modelContext())
    }
    
    func bankAccountsStorage() -> BankAccountsStorage {
        return SwiftDataBankAccountsStorage(modelContext: modelContext())
    }
    
    func categoriesStorage() -> CategoriesStorage {
        return SwiftDataCategoriesStorage(modelContext: modelContext())
    }
    
    func backupStorage() -> BackupStorage {
        return SwiftDataBackupStorage(modelContext: modelContext())
    }
} 
