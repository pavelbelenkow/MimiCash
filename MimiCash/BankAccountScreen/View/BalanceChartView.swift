import SwiftUI
import Charts

struct BalanceChartView: View {
    @Binding var chartState: BalanceChartState
    let currency: String
    
    var body: some View {
        VStack {
            PeriodSelectorView(
                selectedPeriod: $chartState.selectedPeriod,
                showTrend: $chartState.showTrend
            )
            
            AverageBalanceSectionView(
                dataPoints: chartState.dataPoints,
                averageBalance: chartState.averageBalance,
                currency: currency,
                dateRangeText: chartState.dateRangeText,
                isDateSelected: chartState.rawSelectedDate != nil,
                selectedPeriod: chartState.selectedPeriod
            )
            .animation(.easeInOut(duration: 0.3), value: chartState.dataPoints.count)
            .animation(.easeInOut(duration: 0.3), value: chartState.averageBalance)
            
            ZStack {
                if chartState.isLoading {
                    ProgressView("Загрузка данных...")
                        .frame(height: 250)
                        .frame(maxWidth: .infinity)
                        .transition(.opacity)
                } else {
                    BarChart(chartState: $chartState, currency: currency)
                        .frame(height: 250)
                        .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.3), value: chartState.isLoading)
            
            TrendButtonView(
                showTrend: $chartState.showTrend,
                selectedPeriod: chartState.selectedPeriod
            )
            .padding(.top, 16)
        }
        .onAppear {
            initializeScrollPosition()
        }
        .onChange(of: chartState.selectedPeriod) { _, _ in
            initializeScrollPosition()
        }
    }
    
    private func initializeScrollPosition() {
        chartState.scrollPosition = BalanceChartConfiguration.initialScrollPosition(for: chartState.selectedPeriod)
    }
}

// MARK: - Bar Chart

struct BarChart: View {
    @Binding var chartState: BalanceChartState
    let currency: String
    
    // Кэшируем scrollRange для предотвращения пересчетов
    private var scrollRange: (start: Date, end: Date) {
        BalanceChartConfiguration.scrollableDateRange(for: chartState.selectedPeriod)
    }
    
    // Кэшируем видимую длину домена
    private var visibleDomainLength: TimeInterval {
        BalanceChartConfiguration.visibleDomainLength(for: chartState.selectedPeriod)
    }
    
    // Кэшируем scroll target matching
    private var scrollTargetMatching: DateComponents {
        BalanceChartConfiguration.scrollTargetMatching(for: chartState.selectedPeriod)
    }
    
    var body: some View {
        Chart {
            tooltipRuleMark
            averageLineRuleMark
            barMarks
        }
        .chartScrollableAxes(.horizontal)
        .chartXVisibleDomain(length: visibleDomainLength)
        .chartScrollTargetBehavior(
            .valueAligned(matching: scrollTargetMatching)
        )
        .chartScrollPosition(x: $chartState.scrollPosition)
        .chartXSelection(value: $chartState.rawSelectedDate)
        .chartXScale(domain: scrollRange.start...scrollRange.end)
        .chartXAxis {
            AxisMarks { value in
                AxisGridLine()
                AxisTick()
                
                AxisValueLabel {
                    if let date = value.as(Date.self) {
                        Text(BalanceChartDateFormatter.formatXAxisLabel(date, for: chartState.selectedPeriod))
                    }
                }
            }
        }
        .chartOverlay { proxy in
            if
                let selectedDataPoint = chartState.selectedDataPoint,
                let xPosition = proxy.position(forX: selectedDataPoint.date)
            {
                LollypopView(
                    dataPoint: selectedDataPoint,
                    currency: currency,
                    period: chartState.selectedPeriod
                )
                .position(x: xPosition, y: -30)
                .transition(.scale.combined(with: .opacity))
            }
        }
        .onChange(of: chartState.rawSelectedDate) { _, newValue in
            if let date = newValue {
                chartState.selectedDataPoint = BalanceChartConfiguration.findDataPoint(
                    for: date,
                    in: chartState.dataPoints,
                    period: chartState.selectedPeriod
                )
            } else {
                chartState.selectedDataPoint = nil
            }
        }
        .onChange(of: chartState.showTrend) { _, showTrend in
            if showTrend && chartState.selectedPeriod.supportsTrend {
                chartState.scrollPosition = .now
            }
        }
        .animation(.easeInOut(duration: 0.5), value: chartState.dataPoints.count)
        .animation(.easeInOut(duration: 0.3), value: chartState.scrollPosition)
    }
    
    @ChartContentBuilder
    private var tooltipRuleMark: some ChartContent {
        if let selectedDataPoint = chartState.selectedDataPoint {
            RuleMark(
                x: .value("Selected Point", selectedDataPoint.date)
            )
            .foregroundStyle(selectedDataPoint.isPositive ? Color.accent : .red)
            .offset(yStart: -10)
            .zIndex(-1)
        }
    }
    
    @ChartContentBuilder
    private var averageLineRuleMark: some ChartContent {
        if chartState.showTrend && chartState.selectedPeriod.supportsTrend {
            RuleMark(
                xStart: .value("Start", BalanceChartConfiguration.visibleAreaStartDate(for: chartState.selectedPeriod)),
                xEnd: .value("End", Date.now),
                y: .value("Average", chartState.averageBalance)
            )
            .foregroundStyle(Color.navBar)
            .lineStyle(StrokeStyle(lineWidth: 4, lineCap: .round))
            .annotation(position: .top, alignment: .trailing) {
                Text("Average: \(chartState.averageBalance.formattedAsCurrency(code: currency))")
                    .font(.body.bold())
                    .foregroundStyle(Color.navBar)
                    .contentTransition(.numericText())
            }
        }
    }
    
    @ChartContentBuilder
    private var barMarks: some ChartContent {
        ForEach(chartState.dataPoints, id: \.id) { dataPoint in
            BarMark(
                x: .value("Дата", dataPoint.date),
                yStart: .value("Начало", 0),
                yEnd: .value("Баланс", abs(dataPoint.balance))
            )
            .foregroundStyle(
                chartState.showTrend && chartState.selectedPeriod.supportsTrend ?
                    .gray.opacity(0.2) :
                    (dataPoint.isPositive ? .accent : .red)
            )
        }
    }
}

// MARK: - Lollypop View

struct LollypopView: View {
    let dataPoint: BalanceDataPoint
    let currency: String
    let period: BalanceChartPeriod
    
    var body: some View {
        VStack {
            Text(dataPoint.balance.formattedAsCurrency(code: currency))
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Text(BalanceChartDateFormatter.formatTooltipDate(dataPoint.date, for: period))
                .font(.caption)
                .foregroundColor(.navBar)
        }
        .foregroundStyle(.white)
        .padding(12)
        .frame(width: 120)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(dataPoint.isPositive ? Color.accent : .red)
        )
        .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
    }
}

