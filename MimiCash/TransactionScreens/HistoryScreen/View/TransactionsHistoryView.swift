import SwiftUI

struct TransactionsHistoryView: View {
    @State private var viewModel: TransactionsHistoryViewModel
    
    init(viewModel: TransactionsHistoryViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        EntityView(
            state: viewModel.state,
            title: viewModel.title,
            content: { output in
                TransactionsSection(
                    output: viewModel.sortedOutput ?? output,
                    isHistory: true,
                    onTransactionChanged: {
                        Task {
                            await viewModel.loadTransactions(
                                from: viewModel.startDate,
                                to: viewModel.endDate
                            )
                        }
                    }
                ) {
                    TransactionDatePicker(date: $viewModel.startDate, label: "Начало")
                    TransactionDatePicker(date: $viewModel.endDate, label: "Конец")
                    SortPicker(sort: $viewModel.sort)
                }
            }
        )
        .toolbar { toolbarContent }
        .navigationDestination(isPresented: $viewModel.isAnalysisPresented) {
            AnalysisView(
                viewModel: AnalysisViewModelImp(
                    direction: viewModel.direction
                )
            )
        }
        .task {
            await viewModel.loadTransactions(
                from: viewModel.startDate,
                to: viewModel.endDate
            )
        }
        .onChange(of: viewModel.startDate) { _, newStart in
            viewModel.updateStartDate(newStart)
        }
        .onChange(of: viewModel.endDate) { _, newEnd in
            viewModel.updateEndDate(newEnd)
        }
    }
}

// MARK: - Subviews

private extension TransactionsHistoryView {
    
    @ToolbarContentBuilder
    var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                viewModel.presentAnalysis()
            } label: {
                Image(systemName: "document")
            }
        }
    }
}

#Preview {
    TransactionsHistoryView(
        viewModel: TransactionsHistoryViewModelImp(direction: .outcome)
    )
}


