import SwiftUI
import Charts

// MARK: - Period Selector

struct PeriodSelectorView: View {
    @Binding var selectedPeriod: BalanceChartPeriod
    @Binding var showTrend: Bool
    
    var body: some View {
        Picker("Период", selection: $selectedPeriod) {
            ForEach(BalanceChartPeriod.allCases, id: \.self) { period in
                Text(period.rawValue)
                    .tag(period)
            }
        }
        .pickerStyle(.segmented)
        .onChange(of: selectedPeriod) { _, newPeriod in
            if !newPeriod.supportsTrend {
                showTrend = false
            }
        }
    }
}

// MARK: - Average Balance Section

struct AverageBalanceSectionView: View {
    let dataPoints: [BalanceDataPoint]
    let averageBalance: Decimal
    let currency: String
    let dateRangeText: String
    let isDateSelected: Bool
    let selectedPeriod: BalanceChartPeriod
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            if !dataPoints.isEmpty {
                Text(averageBalanceCaption())
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                    .textCase(.uppercase)
                
                Text(averageBalance.formattedAsCurrency(code: currency))
                    .font(.title)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .contentTransition(.numericText())
            } else {
                Text("Нет данных")
                    .font(.title)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
            }
            
            if !dateRangeText.isEmpty {
                Text(dateRangeText)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                    .transition(.opacity.combined(with: .move(edge: .leading)))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .opacity(isDateSelected ? 0.0 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isDateSelected)
    }
    
    private func averageBalanceCaption() -> String {
        switch selectedPeriod {
        case .day:
            return "Всего"
        case .week, .month:
            return "Средний баланс"
        case .sixMonths, .year:
            return "Дневной средний"
        }
    }
}

// MARK: - Trend Button

struct TrendButtonView: View {
    @Binding var showTrend: Bool
    let selectedPeriod: BalanceChartPeriod
    
    var body: some View {
        Button(action: {
            showTrend.toggle()
        }) {
            HStack {
                Text("Тренд")
                
                Spacer()
                
                Text(selectedPeriod.supportsTrend ? "Нет" : "Недоступно")
                    .fontWeight(.medium)
            }
            .padding()
            .font(.subheadline)
            .foregroundStyle(
                selectedPeriod.supportsTrend ?
                Color.primary : Color.secondary
            )
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(
                        selectedPeriod.supportsTrend ? 
                        (showTrend ? Color.navBar : Color.secondary.opacity(0.2)) : 
                        Color.clear
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(
                        selectedPeriod.supportsTrend ? 
                        Color.clear : 
                        Color.secondary.opacity(0.5)
                    )
            )
        }
        .disabled(!selectedPeriod.supportsTrend)
        .buttonStyle(PlainButtonStyle())
    }
}
