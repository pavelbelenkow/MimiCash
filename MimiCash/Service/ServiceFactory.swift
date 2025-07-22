import Foundation

// MARK: - ServiceFactory

final class ServiceFactory {
    
    // MARK: - Singleton
    static let shared = ServiceFactory()
    
    // MARK: - Private Properties
    private let modelContainer: AppModelContainer
    private let syncStatusManager: SyncStatusManager
    
    // MARK: - Init
    private init() {
        self.modelContainer = AppModelContainer.shared
        self.syncStatusManager = SyncStatusManager.shared
    }
    
    // MARK: - Methods
    
    func createTransactionsService() -> TransactionsService {
        let bankAccountsService = createBankAccountsService()
        let serviceCoordinator = ServiceCoordinatorImp(
            bankAccountsService: bankAccountsService
        )
        
        return TransactionsServiceImp(
            storage: modelContainer.transactionsStorage(),
            categoriesStorage: modelContainer.categoriesStorage(),
            bankAccountsStorage: modelContainer.bankAccountsStorage(),
            backupStorage: modelContainer.backupStorage(),
            serviceCoordinator: serviceCoordinator
        )
    }
    
    func createBankAccountsService() -> BankAccountsService {
        return BankAccountsServiceImp(
            storage: modelContainer.bankAccountsStorage(),
            backupStorage: modelContainer.backupStorage(),
        )
    }
    
    func createCategoriesService() -> CategoriesService {
        return CategoriesServiceImp(
            storage: modelContainer.categoriesStorage()
        )
    }
    
    // MARK: - Private Methods
    
    func getSyncStatusManager() -> SyncStatusManager {
        return syncStatusManager
    }
} 
