import SwiftUI

struct TransactionFormModalView {
    
    @MainActor
    static func createHostingController(
        transaction: Transaction,
        diContainer: AppDIContainer,
        onDismiss: @escaping () -> Void,
        onTransactionChanged: @escaping () -> Void
    ) -> UIHostingController<TransactionFormView> {
        let hostingController = UIHostingController(
            rootView: TransactionFormView(
                viewModel: TransactionFormViewModelImp(
                    mode: .edit(transaction: transaction),
                    transactionsService: diContainer.transactionsService,
                    categoriesService: diContainer.categoriesService,
                    bankAccountsService: diContainer.bankAccountsService
                ),
                onDismiss: onDismiss,
                onTransactionChanged: onTransactionChanged
            )
        )
        
        hostingController.view.tintColor = .navBar
        hostingController.navigationController?.navigationBar.tintColor = .navBar
        hostingController.modalPresentationStyle = .fullScreen
        
        return hostingController
    }
}
