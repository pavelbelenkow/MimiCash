import Foundation

struct BalanceChartConfiguration {
    
    // Кэш для предотвращения лишних вычислений
    private static var scrollTargetMatchingCache: [BalanceChartPeriod: DateComponents] = [:]
    private static var scrollTargetMajorAlignmentCache: [BalanceChartPeriod: DateComponents] = [:]
    private static var scrollableDateRangeCache: [BalanceChartPeriod: (start: Date, end: Date)] = [:]
    private static var visibleDomainLengthCache: [BalanceChartPeriod: TimeInterval] = [:]
    private static var initialScrollPositionCache: [BalanceChartPeriod: Date] = [:]
    
    static func scrollTargetMatching(for period: BalanceChartPeriod) -> DateComponents {
        if let cached = scrollTargetMatchingCache[period] {
            return cached
        }
        
        let result: DateComponents
        switch period {
        case .day: result = DateComponents(hour: 0)
        case .week: result = DateComponents(day: 1)
        case .month: result = DateComponents(day: 1)
        case .sixMonths: result = DateComponents(month: 1)
        case .year: result = DateComponents(month: 1)
        }
        
        scrollTargetMatchingCache[period] = result
        return result
    }
    
    static func scrollTargetMajorAlignment(for period: BalanceChartPeriod) -> DateComponents {
        if let cached = scrollTargetMajorAlignmentCache[period] {
            return cached
        }
        
        let result: DateComponents
        switch period {
        case .day: result = DateComponents(hour: 1)
        case .week: result = DateComponents(weekOfYear: 1)
        case .month: result = DateComponents(month: 1)
        case .sixMonths: result = DateComponents(month: 1)
        case .year: result = DateComponents(year: 1)
        }
        
        scrollTargetMajorAlignmentCache[period] = result
        return result
    }
    
    static func customStrideValues(for period: BalanceChartPeriod, scrollPosition: Date = Date()) -> [Date] {
        let calendar = Calendar.current
        
        switch period {
        case .day:
            // Для дня: каждые 4 часа от начала дня до конца дня
            let startOfDay = calendar.startOfDay(for: scrollPosition)
            let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) ?? scrollPosition
            return stride(from: 0, through: 20, by: 4).compactMap { hour in
                let date = calendar.date(byAdding: .hour, value: hour, to: startOfDay) ?? startOfDay
                return date < endOfDay ? date : nil
            }
            
        case .week:
            // Для недели: каждый день недели
            let weekInterval = calendar.dateInterval(of: .weekOfYear, for: scrollPosition)
            let weekStart = weekInterval?.start ?? scrollPosition
            return stride(from: 0, through: 6, by: 1).compactMap { dayOffset in
                calendar.date(byAdding: .day, value: dayOffset, to: weekStart)
            }
            
        case .month:
            // Для месяца: каждые 5 дней от начала месяца
            let monthInterval = calendar.dateInterval(of: .month, for: scrollPosition)
            let monthStart = monthInterval?.start ?? scrollPosition
            let monthEnd = monthInterval?.end ?? scrollPosition
            
            var dates: [Date] = []
            var currentDate = monthStart
            
            while currentDate < monthEnd {
                dates.append(currentDate)
                currentDate = calendar.date(byAdding: .day, value: 5, to: currentDate) ?? currentDate
            }
            
            // Добавляем конец месяца, если его нет
            if !dates.contains(where: { calendar.isDate($0, equalTo: monthEnd, toGranularity: .day) }) {
                dates.append(monthEnd)
            }
            
            return dates
            
        case .sixMonths:
            // Для полугода: каждый месяц
            let end = scrollPosition
            let start = calendar.date(byAdding: .month, value: -5, to: end) ?? end
            
            return stride(from: 0, through: 5, by: 1).compactMap { monthOffset in
                calendar.date(byAdding: .month, value: monthOffset, to: start)
            }
            
        case .year:
            // Для года: каждый месяц
            let end = scrollPosition
            let start = calendar.date(byAdding: .month, value: -11, to: end) ?? end
            
            return stride(from: 0, through: 11, by: 1).compactMap { monthOffset in
                calendar.date(byAdding: .month, value: monthOffset, to: start)
            }
        }
    }
    
    static func visibleAreaStartDate(for period: BalanceChartPeriod) -> Date {
        let calendar = Calendar.current
        let now = Date()
        
        switch period {
        case .month:
            // Начало видимой области: 30 дней назад от сегодня
            return calendar.date(byAdding: .day, value: -30, to: now) ?? now
        case .sixMonths:
            // Начало видимой области: 6 месяцев назад от сегодня
            return calendar.date(byAdding: .month, value: -6, to: now) ?? now
        default:
            return now
        }
    }
    
    // Метод для вычисления допустимого диапазона скролла
    static func scrollableDateRange(for period: BalanceChartPeriod) -> (start: Date, end: Date) {
        if let cached = scrollableDateRangeCache[period] {
            return cached
        }
        
        let calendar = Calendar.current
        let now = Date()
        
        let result: (start: Date, end: Date)
        switch period {
        case .day:
            // Для дня: можно скроллить в пределах текущего дня
            let startOfDay = calendar.startOfDay(for: now)
            let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) ?? now
            result = (startOfDay, endOfDay)
            
        case .week:
            // Для недели: можно скроллить в пределах текущей недели
            let weekInterval = calendar.dateInterval(of: .weekOfYear, for: now)
            let weekStart = weekInterval?.start ?? now
            let weekEnd = calendar.date(byAdding: .day, value: 7, to: weekStart) ?? now
            result = (weekStart, weekEnd)
            
        case .month:
            // Для месяца: можно скроллить в пределах текущего месяца
            let monthInterval = calendar.dateInterval(of: .month, for: now)
            let monthStart = monthInterval?.start ?? now
            let monthEnd = monthInterval?.end ?? now
            result = (monthStart, monthEnd)
            
        case .sixMonths:
            // Для полугода: можно скроллить от 6 месяцев назад до сейчас
            let start = calendar.date(byAdding: .month, value: -5, to: now) ?? now
            result = (start, now)
            
        case .year:
            // Для года: можно скроллить от 12 месяцев назад до сейчас
            let start = calendar.date(byAdding: .month, value: -11, to: now) ?? now
            result = (start, now)
        }
        
        scrollableDateRangeCache[period] = result
        return result
    }
    
    // Метод для получения длины видимой области в зависимости от периода
    static func visibleDomainLength(for period: BalanceChartPeriod) -> TimeInterval {
        if let cached = visibleDomainLengthCache[period] {
            return cached
        }
        
        let result: TimeInterval
        switch period {
        case .day: result = 3600 * 24 // 1 день
        case .week: result = 3600 * 24 * 7 // 7 дней
        case .month: result = 3600 * 24 * 30 // 30 дней
        case .sixMonths: result = 3600 * 24 * 30 * 6 // 6 месяцев (180 дней)
        case .year: result = 3600 * 24 * 365 // 1 год
        }
        
        visibleDomainLengthCache[period] = result
        return result
    }
    
    static func findDataPoint(for date: Date, in dataPoints: [BalanceDataPoint], period: BalanceChartPeriod) -> BalanceDataPoint? {
        let calendar = Calendar.current
        let sortedPoints = dataPoints.sorted { $0.date < $1.date }
        
        switch period {
        case .day:
            return sortedPoints.last(where: {
                calendar.isDate($0.date, equalTo: date, toGranularity: .hour) ||
                $0.date <= date
            })
        case .week, .month:
            return sortedPoints.last(where: {
                calendar.isDate($0.date, equalTo: date, toGranularity: .day) ||
                $0.date <= date
            })
        case .sixMonths:
            return sortedPoints.last(where: {
                calendar.isDate($0.date, equalTo: date, toGranularity: .weekOfYear) ||
                $0.date <= date
            })
        case .year:
            return sortedPoints.last(where: {
                calendar.isDate($0.date, equalTo: date, toGranularity: .month) ||
                $0.date <= date
            })
        }
    }
    
    // Метод для получения начальной позиции скролла
    static func initialScrollPosition(for period: BalanceChartPeriod) -> Date {
        if let cached = initialScrollPositionCache[period] {
            return cached
        }
        
        let calendar = Calendar.current
        let now = Date()
        
        let result: Date
        switch period {
        case .day:
            // Для дня: начинаем с сегодняшнего дня
            result = calendar.startOfDay(for: now)
        case .week:
            // Для недели: начинаем с начала текущей недели
            result = calendar.dateInterval(of: .weekOfYear, for: now)?.start ?? now
        case .month:
            // Для месяца: начинаем с начала текущего месяца
            result = calendar.dateInterval(of: .month, for: now)?.start ?? now
        case .sixMonths:
            // Для полугода: начинаем с текущего месяца (конец диапазона)
            result = now
        case .year:
            // Для года: начинаем с текущего месяца (конец диапазона)
            result = now
        }
        
        initialScrollPositionCache[period] = result
        return result
    }
    
    // Метод для очистки кэша
    static func clearCache() {
        scrollTargetMatchingCache.removeAll()
        scrollTargetMajorAlignmentCache.removeAll()
        scrollableDateRangeCache.removeAll()
        visibleDomainLengthCache.removeAll()
        initialScrollPositionCache.removeAll()
    }
}
