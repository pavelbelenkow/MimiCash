import SwiftUI

struct BalanceChartSection: View {
    @Binding var viewModel: any BankAccountViewModel
    
    var body: some View {
        Section {
            if !viewModel.state.isEditing {
                chartContent
            }
        }
        .listRowBackground(Color.clear)
        .listRowInsets(.init())
    }
    
    private var chartContent: some View {
        BalanceChartView(
            chartState: $viewModel.state.chartState,
            currency: viewModel.state.selectedCurrency
        )
        .onChange(of: viewModel.state.chartState.selectedPeriod) { _, newPeriod in
            Task {
                await viewModel.handleChartPeriodChange(newPeriod)
            }
        }
        .task {
            await viewModel.loadBalanceChartData()
        }
    }
}
