import SwiftData
import SwiftUI

@MainActor
final class AppDIContainer: ObservableObject {
    let modelContainer: ModelContainer

    let transactionsStorage: TransactionsStorage
    let bankAccountsStorage: BankAccountsStorage
    let categoriesStorage: CategoriesStorage
    let backupStorage: BackupStorage

    let transactionsService: TransactionsService
    let bankAccountsService: BankAccountsService
    let categoriesService: CategoriesService
    let balanceChartService: BalanceChartService

    init() {
        let schema = Schema([
            TransactionModel.self,
            BankAccountModel.self,
            CategoryModel.self,
            BackupOperationModel.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        self.modelContainer = try! ModelContainer(for: schema, configurations: [modelConfiguration])

        self.transactionsStorage = SwiftDataTransactionsStorage(modelContext: modelContainer.mainContext)
        self.bankAccountsStorage = SwiftDataBankAccountsStorage(modelContext: modelContainer.mainContext)
        self.categoriesStorage = SwiftDataCategoriesStorage(modelContext: modelContainer.mainContext)
        self.backupStorage = SwiftDataBackupStorage(modelContext: modelContainer.mainContext)

        self.bankAccountsService = BankAccountsServiceImp(
            storage: bankAccountsStorage,
            backupStorage: backupStorage
        )
        self.categoriesService = CategoriesServiceImp(
            storage: categoriesStorage
        )
        self.transactionsService = TransactionsServiceImp(
            storage: transactionsStorage,
            categoriesStorage: categoriesStorage,
            bankAccountsStorage: bankAccountsStorage,
            backupStorage: backupStorage,
            serviceCoordinator: ServiceCoordinatorImp(bankAccountsService: bankAccountsService)
        )
        
        self.balanceChartService = BalanceChartServiceImpl(
            transactionsService: transactionsService
        )
    }
}

@MainActor
private struct DIContainerKey: @preconcurrency EnvironmentKey {
    static let defaultValue: AppDIContainer = .init()
}

extension EnvironmentValues {
    var diContainer: AppDIContainer {
        get { self[DIContainerKey.self] }
        set { self[DIContainerKey.self] = newValue }
    }
}
