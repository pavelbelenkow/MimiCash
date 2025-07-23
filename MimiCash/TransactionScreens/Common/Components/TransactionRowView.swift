import SwiftUI

struct TransactionRowView: View {
    let transaction: Transaction
    let isHistoryView: Bool
    let onTransactionChanged: (() -> Void)?
    @Environment(\.diContainer) private var diContainer
    @State private var isEditPresented = false
    
    init(transaction: Transaction, isHistoryView: Bool, onTransactionChanged: (() -> Void)? = nil) {
        self.transaction = transaction
        self.isHistoryView = isHistoryView
        self.onTransactionChanged = onTransactionChanged
    }
    
    var body: some View {
        ZStack {
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture {
                    isEditPresented = true
                }
            
            HStack(spacing: 12) {
                if transaction.category.isIncome == .outcome {
                    ZStack {
                        Circle()
                            .fill(Color.circle)
                        Text(transaction.category.emoji.description)
                            .font(.system(size: 12))
                    }
                    .frame(width: 22, height: 22)
                }
                
                VStack(alignment: .leading) {
                    Text(transaction.category.name)
                    
                    if let comment = transaction.comment, !comment.isEmpty {
                        Text(comment)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text(transaction.formattedAmount())
                    
                    if isHistoryView {
                        Text(transaction.formattedDate())
                    }
                }
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.secondary)
            }
        }
        .fullScreenCover(isPresented: $isEditPresented) {
            TransactionFormView(
                viewModel: TransactionFormViewModelImp(
                    mode: .edit(transaction: transaction),
                    transactionsService: diContainer.transactionsService,
                    categoriesService: diContainer.categoriesService,
                    bankAccountsService: diContainer.bankAccountsService
                ),
                onDismiss: {
                    isEditPresented = false
                },
                onTransactionChanged: onTransactionChanged
            )
        }
    }
}
