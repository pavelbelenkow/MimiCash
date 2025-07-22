import Foundation

extension Date {
    
    /// Возвращает начало текущего дня (00:00:00)
    static var startOfToday: Date {
        Calendar.current.startOfDay(for: Date())
    }
    
    /// Возвращает конец текущего дня (23:59:59)
    static var endOfToday: Date {
        let calendar = Calendar.current
        let nextDay = calendar.date(
            byAdding: .day,
            value: 1,
            to: startOfToday
        ) ?? Date()
        
        return calendar.date(
            byAdding: .second,
            value: -1,
            to: nextDay
        ) ?? Date()
    }
    
    /// Возвращает начало дня (00:00:00) ровно месяц назад от текущей даты
    static var monthAgo: Date {
        let calendar = Calendar.current
        let monthAgoDate = calendar.date(
            byAdding: .month,
            value: -1,
            to: Date()
        ) ?? Date()
        
        return calendar.startOfDay(for: monthAgoDate)
    }
    
    /// Возвращает начало дня (00:00:00) для текущей даты
    var dayStart: Date {
        Calendar.current.startOfDay(for: self)
    }
    
    /// Возвращает конец дня (23:59:59) для текущей даты
    var dayEnd: Date {
        let calendar = Calendar.current
        let nextDay = calendar.date(
            byAdding: .day,
            value: 1,
            to: dayStart
        ) ?? self
        
        return calendar.date(
            byAdding: .second,
            value: -1,
            to: nextDay
        ) ?? self
    }
}
