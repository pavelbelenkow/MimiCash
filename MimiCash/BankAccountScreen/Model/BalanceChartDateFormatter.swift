import Foundation

struct BalanceChartDateFormatter {
    
    static func formatDateRange(
        for period: BalanceChartPeriod,
        startDate: Date,
        endDate: Date
    ) -> String {
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        
        switch period {
        case .day:
            return formatDayRange(startDate: startDate, endDate: endDate, calendar: calendar, formatter: formatter)
        case .week:
            return formatWeekRange(startDate: startDate, endDate: endDate, calendar: calendar, formatter: formatter)
        case .month:
            return formatMonthRange(startDate: startDate, endDate: endDate, calendar: calendar, formatter: formatter)
        case .sixMonths:
            return formatSixMonthsRange(startDate: startDate, endDate: endDate, calendar: calendar, formatter: formatter)
        case .year:
            return formatYearRange(startDate: startDate, endDate: endDate, calendar: calendar, formatter: formatter)
        }
    }
    
    static func formatSelectedDate(_ date: Date, for period: BalanceChartPeriod) -> String {
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        
        switch period {
        case .day:
            if calendar.isDateInToday(date) {
                return "Today"
            } else {
                formatter.dateFormat = "MMM d, HH:mm"
                return formatter.string(from: date)
            }
        case .week:
            formatter.dateFormat = "E, d MMM"
            return formatter.string(from: date)
        case .month:
            formatter.dateFormat = "d MMM"
            return formatter.string(from: date)
        case .sixMonths:
            formatter.dateFormat = "MMM yyyy"
            return formatter.string(from: date)
        case .year:
            formatter.dateFormat = "MMM yyyy"
            return formatter.string(from: date)
        }
    }
    
    private static func formatDayRange(startDate: Date, endDate: Date, calendar: Calendar, formatter: DateFormatter) -> String {
        if calendar.isDateInToday(startDate) {
            return "Today"
        } else {
            formatter.dateFormat = "MMM d, HH:mm"
            let startStr = formatter.string(from: startDate)
            let endStr = formatter.string(from: endDate)
            return "\(startStr) – \(endStr)"
        }
    }
    
    private static func formatWeekRange(startDate: Date, endDate: Date, calendar: Calendar, formatter: DateFormatter) -> String {
        formatter.dateFormat = "MMM d"
        let startStr = formatter.string(from: startDate)
        let endStr = formatter.string(from: endDate)
        let year = calendar.component(.year, from: endDate)
        return "\(startStr)–\(endStr), \(year)"
    }
    
    private static func formatMonthRange(startDate: Date, endDate: Date, calendar: Calendar, formatter: DateFormatter) -> String {
        formatter.dateFormat = "MMM d"
        let startStr = formatter.string(from: startDate)
        let endStr = formatter.string(from: calendar.date(byAdding: .day, value: -1, to: endDate) ?? endDate)
        let year = calendar.component(.year, from: endDate)
        return "\(startStr) – \(endStr), \(year)"
    }
    
    private static func formatSixMonthsRange(startDate: Date, endDate: Date, calendar: Calendar, formatter: DateFormatter) -> String {
        formatter.dateFormat = "MMM d"
        let startStr = formatter.string(from: startDate)
        let endStr = formatter.string(from: endDate)
        let year = calendar.component(.year, from: endDate)
        return "\(startStr) – \(endStr), \(year)"
    }
    
    private static func formatYearRange(startDate: Date, endDate: Date, calendar: Calendar, formatter: DateFormatter) -> String {
        formatter.dateFormat = "MMM yyyy"
        let startStr = formatter.string(from: startDate)
        let endStr = formatter.string(from: endDate)
        return "\(startStr) – \(endStr)"
    }
    
    static func formatTooltipDate(_ date: Date, for period: BalanceChartPeriod) -> String {
        let formatter = DateFormatter()
        
        switch period {
        case .day:
            formatter.dateFormat = "HH:mm"
        case .week:
            formatter.dateFormat = "E, d MMM"
        case .month:
            formatter.dateFormat = "d MMM"
        case .sixMonths:
            formatter.dateFormat = "MMM yyyy"
        case .year:
            formatter.dateFormat = "MMM yyyy"
        }
        
        return formatter.string(from: date)
    }
    
    static func formatXAxisLabel(_ date: Date, for period: BalanceChartPeriod) -> String {
        let calendar = Calendar.current
        
        switch period {
        case .day:
            let hour = calendar.component(.hour, from: date)
            return String(format: "%02d", hour)
        case .week:
            let formatter = DateFormatter()
            formatter.dateFormat = "E"
            return formatter.string(from: date)
        case .month:
            let day = calendar.component(.day, from: date)
            return "\(day)"
        case .sixMonths:
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM"
            return formatter.string(from: date)
        case .year:
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM"
            return formatter.string(from: date).prefix(1).uppercased()
        }
    }
}
