import SwiftUI

struct TransactionsListView: View {
    @State private var viewModel: TransactionsListViewModel
    
    init(viewModel: TransactionsListViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        NavigationStack {
            EntityView(
                state: viewModel.state,
                title: viewModel.title,
                content: { output in
                    ZStack(alignment: .bottomTrailing) {
                        TransactionsSection(
                            output: output,
                            isHistory: false,
                            onTransactionChanged: {
                                Task {
                                    await viewModel.loadTransactions(
                                        from: .startOfToday,
                                        to: .endOfToday
                                    )
                                }
                            }
                        ) {
                            EmptyView()
                        }
                        
                        FloatingButton {
                            viewModel.presentAddTransaction()
                        }
                    }
                }
            )
            .toolbar { toolbarContent }
            .navigationDestination(isPresented: $viewModel.isHistoryPresented) {
                TransactionsHistoryView(
                    viewModel: TransactionsHistoryViewModelImp(
                        direction: viewModel.direction
                    )
                )
            }
            .fullScreenCover(isPresented: $viewModel.isAddTransactionPresented) {
                TransactionFormView(
                    viewModel: TransactionFormViewModelImp(
                        mode: .create(direction: viewModel.direction)
                    ),
                    onDismiss: {
                        viewModel.isAddTransactionPresented = false
                    },
                    onTransactionChanged: {
                        Task {
                            await viewModel.loadTransactions(
                                from: .startOfToday,
                                to: .endOfToday
                            )
                        }
                    }
                )
            }
        }
        .tint(.navBar)
        .task {
            await viewModel.loadTransactions(
                from: .startOfToday,
                to: .endOfToday
            )
        }
    }
}

// MARK: - Subviews

private extension TransactionsListView {
    
    @ToolbarContentBuilder
    var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                viewModel.presentTransactionHistory()
            } label: {
                Image(systemName: "clock")
            }
        }
    }
}

#Preview {
    TransactionsListView(
        viewModel: TransactionsListViewModelImp(direction: .outcome)
    )
}

