import SwiftUI

struct TransactionFormModalView {
    
    static func createHostingController(
        transaction: Transaction,
        onDismiss: @escaping () -> Void,
        onTransactionChanged: @escaping () -> Void
    ) -> UIHostingController<TransactionFormView> {
        let hostingController = UIHostingController(
            rootView: TransactionFormView(
                viewModel: TransactionFormViewModelImp(
                    mode: .edit(transaction: transaction)
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
