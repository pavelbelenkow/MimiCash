import Foundation

protocol BalanceChartService {
    func calculateBalanceData(
        for period: BalanceChartPeriod,
        accountId: Int,
        currentBalance: Decimal
    ) async -> [BalanceDataPoint]
}

final class BalanceChartServiceImpl: BalanceChartService {
    
    private let transactionsService: TransactionsService
    
    init(transactionsService: TransactionsService) {
        self.transactionsService = transactionsService
    }
    
    func calculateBalanceData(
        for period: BalanceChartPeriod,
        accountId: Int,
        currentBalance: Decimal
    ) async -> [BalanceDataPoint] {
        let (startDate, endDate) = getExtendedDateRange()
        let transactions: [Transaction]
        
        do {
            transactions = try await transactionsService.fetchTransactions(
                accountId: accountId,
                from: startDate,
                to: endDate
            )
        } catch {
            return []
        }
        
        return await Task.detached(priority: .userInitiated) {
            await self.processTransactions(
                transactions,
                for: period,
                currentBalance: currentBalance
            )
        }.value
    }
    
    private func processTransactions(
        _ transactions: [Transaction],
        for period: BalanceChartPeriod,
        currentBalance: Decimal
    ) async -> [BalanceDataPoint] {
        let sortedTransactions = transactions.sorted { $0.transactionDate > $1.transactionDate }
        
        let result: [BalanceDataPoint]
        switch period {
        case .day:
            result = calculateHourlyBalanceForExtendedRange(for: sortedTransactions, currentBalance: currentBalance)
        case .week, .month:
            result = calculateDailyBalanceForExtendedRange(for: sortedTransactions, currentBalance: currentBalance)
        case .sixMonths, .year:
            result = calculateMonthlyBalanceForExtendedRange(for: sortedTransactions, currentBalance: currentBalance)
        }
        
        return result
    }
    
    private func getExtendedDateRange() -> (Date, Date) {
        let calendar = Calendar.current
        let now = Date()
        
        let startDate = calendar.date(byAdding: .year, value: -5, to: now) ?? now
        let endDate = now
        
        return (startDate, endDate)
    }
    
    private func calculateBalance(from transactions: [Transaction]) -> Decimal {
        let balance = transactions.reduce(Decimal(0)) { total, transaction in
            let amount = transaction.amount
            return transaction.category.isIncome == .income ? total + amount : total - amount
        }
        
        return balance
    }
    
    // MARK: - Extended Range Methods
    
    private func calculateHourlyBalanceForExtendedRange(for transactions: [Transaction], currentBalance: Decimal) -> [BalanceDataPoint] {
        let calendar = Calendar.current
        let now = Date()
        let startDate = calendar.date(byAdding: .year, value: -5, to: now) ?? now
        var dataPoints: [BalanceDataPoint] = []
        var runningBalance: Decimal = currentBalance
        
        let transactionsBeforeStart = transactions.filter { $0.transactionDate < startDate }
        runningBalance -= calculateBalance(from: transactionsBeforeStart)
        
        let transactionsByHour = Dictionary(grouping: transactions.filter { $0.transactionDate >= startDate }) { transaction in
            let components = calendar.dateComponents([.year, .month, .day, .hour], from: transaction.transactionDate)
            return calendar.date(from: components) ?? transaction.transactionDate
        }
        
        let sortedHours = transactionsByHour.keys.sorted()
        
        for hour in sortedHours {
            let hourTransactions = transactionsByHour[hour] ?? []
            let hourBalance = calculateBalance(from: hourTransactions)
            runningBalance -= hourBalance
            
            dataPoints.append(BalanceDataPoint(date: hour, balance: runningBalance))
        }
        
        return dataPoints
    }
    
    private func calculateDailyBalanceForExtendedRange(for transactions: [Transaction], currentBalance: Decimal) -> [BalanceDataPoint] {
        let calendar = Calendar.current
        let now = Date()
        let startDate = calendar.date(byAdding: .year, value: -5, to: now) ?? now
        var dataPoints: [BalanceDataPoint] = []
        var runningBalance: Decimal = currentBalance
        
        let transactionsBeforeStart = transactions.filter { $0.transactionDate < startDate }
        runningBalance -= calculateBalance(from: transactionsBeforeStart)
        
        let transactionsByDay = Dictionary(grouping: transactions.filter { $0.transactionDate >= startDate }) { transaction in
            calendar.startOfDay(for: transaction.transactionDate)
        }
        
        let sortedDays = transactionsByDay.keys.sorted()
        
        for day in sortedDays {
            let dayTransactions = transactionsByDay[day] ?? []
            let dayBalance = calculateBalance(from: dayTransactions)
            runningBalance -= dayBalance
            
            dataPoints.append(BalanceDataPoint(date: day, balance: runningBalance))
        }
        
        return dataPoints
    }
    
    private func calculateMonthlyBalanceForExtendedRange(for transactions: [Transaction], currentBalance: Decimal) -> [BalanceDataPoint] {
        let calendar = Calendar.current
        let now = Date()
        let startDate = calendar.date(byAdding: .year, value: -5, to: now) ?? now
        var dataPoints: [BalanceDataPoint] = []
        var runningBalance: Decimal = currentBalance
        
        let transactionsBeforeStart = transactions.filter { $0.transactionDate < startDate }
        runningBalance -= calculateBalance(from: transactionsBeforeStart)
        
        let transactionsByMonth = Dictionary(grouping: transactions.filter { $0.transactionDate >= startDate }) { transaction in
            let components = calendar.dateComponents([.year, .month], from: transaction.transactionDate)
            return calendar.date(from: components) ?? transaction.transactionDate
        }
        
        let sortedMonths = transactionsByMonth.keys.sorted()
        
        for month in sortedMonths {
            let monthTransactions = transactionsByMonth[month] ?? []
            let monthBalance = calculateBalance(from: monthTransactions)
            runningBalance -= monthBalance
            
            dataPoints.append(BalanceDataPoint(date: month, balance: runningBalance))
        }
        
        return dataPoints
    }
} 
