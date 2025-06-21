import Foundation

extension Date {
    static var startOfToday: Date {
        Calendar.current.startOfDay(for: Date())
    }
    
    static var endOfToday: Date {
        let calendar = Calendar.current
        return calendar.date(
            bySettingHour: 23,
            minute: 59,
            second: 59,
            of: startOfToday
        ) ?? Date()
    }
    
    static var monthAgo: Date {
        Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
    }
}
