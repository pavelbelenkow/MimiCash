import Foundation
import Charts

// MARK: - Balance Chart Period

enum BalanceChartPeriod: String, CaseIterable {
    case day = "D"
    case week = "W"
    case month = "M"
    case sixMonths = "6M"
    case year = "Y"
    
    var supportsTrend: Bool {
        self == .month || self == .sixMonths
    }
}

// MARK: - Balance Data Point

struct BalanceDataPoint: Identifiable, Equatable {
    let id = UUID()
    let date: Date
    let balance: Decimal
    let isPositive: Bool
    
    init(date: Date, balance: Decimal) {
        self.date = date
        self.balance = balance
        self.isPositive = balance >= 0
    }
}

// MARK: - Balance Chart State

struct BalanceChartState {
    var selectedPeriod: BalanceChartPeriod = .month
    var dataPoints: [BalanceDataPoint] = []
    var isLoading: Bool = false
    var showTrend: Bool = false
    var selectedDataPoint: BalanceDataPoint?
    var scrollPosition: Date = Date()
    var rawSelectedDate: Date?
    
    var averageBalance: Decimal {
        guard !dataPoints.isEmpty else { return 0 }
        let sum = dataPoints.reduce(0) { $0 + $1.balance }
        return sum / Decimal(dataPoints.count)
    }
    
    var dateRangeText: String {
        guard !dataPoints.isEmpty else { return "" }
        
        if let selectedDate = rawSelectedDate {
            return BalanceChartDateFormatter.formatSelectedDate(selectedDate, for: selectedPeriod)
        }
        
        let visibleRange = calculateVisibleDateRange()
        return BalanceChartDateFormatter.formatDateRange(
            for: selectedPeriod,
            startDate: visibleRange.start,
            endDate: visibleRange.end
        )
    }
    
    private func calculateVisibleDateRange() -> (start: Date, end: Date) {
        let calendar = Calendar.current
        
        switch selectedPeriod {
        case .day:
            // Для дня: показываем 24 часа от scrollPosition
            let start = calendar.startOfDay(for: scrollPosition)
            let end = calendar.date(byAdding: .day, value: 1, to: start) ?? start
            return (start, end)
            
        case .week:
            // Для недели: показываем неделю от scrollPosition
            let weekInterval = calendar.dateInterval(of: .weekOfYear, for: scrollPosition)
            let start = weekInterval?.start ?? scrollPosition
            let end = calendar.date(byAdding: .day, value: 7, to: start) ?? start
            return (start, end)
            
        case .month:
            // Для месяца: показываем месяц от scrollPosition
            let monthInterval = calendar.dateInterval(of: .month, for: scrollPosition)
            let start = monthInterval?.start ?? scrollPosition
            let end = monthInterval?.end ?? start
            return (start, end)
            
        case .sixMonths:
            // Для полугода: показываем 6 месяцев назад от scrollPosition
            let end = scrollPosition
            let start = calendar.date(byAdding: .month, value: -5, to: end) ?? end
            return (start, end)
            
        case .year:
            // Для года: показываем 12 месяцев назад от scrollPosition
            let end = scrollPosition
            let start = calendar.date(byAdding: .month, value: -11, to: end) ?? end
            return (start, end)
        }
    }
}
