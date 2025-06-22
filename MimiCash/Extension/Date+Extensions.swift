import Foundation

extension Date {
    static var startOfToday: Date {
        Calendar.current.startOfDay(for: Date())
    }
    
    static var endOfToday: Date {
        let calendar = Calendar.current
        return calendar.date(
            byAdding: .day,
            value: 1,
            to: startOfToday
        ) ?? Date()
    }
    
    static var monthAgo: Date {
        Calendar.current.date(
            byAdding: .month,
            value: -1,
            to: Date()
        ) ?? Date()
    }
}
