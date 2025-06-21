import SwiftUI

struct TransactionsHistoryView: View {
    @State private var viewModel: TransactionsViewModel
    @State private var startDate: Date = .monthAgo
    @State private var endDate: Date = Date()
    @State private var showAnalyse = false
    
    init(viewModel: TransactionsViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        EntityView(
            state: viewModel.state,
            title: "Моя история",
            loadingText: "Загружаемся...",
            errorPrefix: "Ошибка: ",
            content: { output in
                TransactionsSection(
                    output: viewModel.sortedOutput ?? output,
                    isHistory: true
                ) {
                    TransactionDatePicker(label: "Начало", date: $startDate)
                    TransactionDatePicker(label: "Конец", date: $endDate)
                    SortPicker(sort: $viewModel.sort)
                }
            }
        )
        .toolbar { toolbarContent }
        .navigationDestination(isPresented: $showAnalyse) {
            Text("Анализ")
        }
        .task {
            await viewModel.loadTransactions(from: startDate, to: endDate)
        }
        .onChange(of: startDate) { _, newStart in
            if newStart > endDate {
                endDate = newStart
            }
            Task {
                await viewModel.loadTransactions(
                    from: startDate,
                    to: endDate
                )
            }
        }
        .onChange(of: endDate) { _, newEnd in
            if newEnd < startDate {
                startDate = newEnd
            }
            Task {
                await viewModel.loadTransactions(
                    from: startDate,
                    to: endDate
                )
            }
        }
    }
}

// MARK: - Subviews

private extension TransactionsHistoryView {
    
    @ToolbarContentBuilder
    var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                showAnalyse = true
            } label: {
                Image(systemName: "document")
            }
        }
    }
}

#Preview {
    TransactionsHistoryView(
        viewModel: TransactionsViewModelImp(direction: .outcome)
    )
}


