import SwiftUI

struct TransactionsListView: View {
    @State private var viewModel: TransactionsViewModel
    @State private var showHistory = false
    @State private var isPresented = false
    
    init(viewModel: TransactionsViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        NavigationStack {
            EntityView(
                state: viewModel.state,
                title: viewModel.title,
                loadingText: "Загружаемся...",
                errorPrefix: "Ошибка: ",
                content: { output in
                    ZStack(alignment: .bottomTrailing) {
                        TransactionsSection(
                            output: output,
                            isHistory: false) {
                                EmptyView()
                            }
                        
                        FloatingButton {
                            isPresented = true
                        }
                    }
                }
            )
            .toolbar { toolbarContent }
            .navigationDestination(isPresented: $showHistory) {
                TransactionsHistoryView(
                    viewModel: TransactionsViewModelImp(direction: viewModel.direction)
                )
            }
            .fullScreenCover(isPresented: $isPresented) {
                Text("Добавить транзакцию")
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
                showHistory = true
            } label: {
                Image(systemName: "clock")
            }
        }
    }
}

#Preview {
    TransactionsListView(
        viewModel: TransactionsViewModelImp(direction: .outcome)
    )
}

