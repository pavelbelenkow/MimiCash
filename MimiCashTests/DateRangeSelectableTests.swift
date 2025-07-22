import XCTest
@testable import MimiCash

// MARK: - DateRangeSelectable Tests

final class DateRangeSelectableTests: XCTestCase {
    
    private var mockViewModel: MockDateRangeSelectable!
    private let calendar = Calendar.current
    
    override func setUp() {
        super.setUp()
        mockViewModel = MockDateRangeSelectable()
    }
    
    // MARK: - updateStartDate Tests
    
    func test_updateStartDate_normalizeToStartOfDay() {
        // Arrange
        let dateWithTime = createDate(day: 15, month: 12, year: 2024, hour: 14, minute: 30, second: 45)
        let expectedStart = dateWithTime.dayStart
        
        // Act
        mockViewModel.updateStartDate(dateWithTime)
        
        // Assert
        XCTAssertEqual(mockViewModel.startDate, expectedStart)
        XCTAssertEqual(calendar.component(.hour, from: mockViewModel.startDate), 0)
        XCTAssertEqual(calendar.component(.minute, from: mockViewModel.startDate), 0)
        XCTAssertEqual(calendar.component(.second, from: mockViewModel.startDate), 0)
    }
    
    func test_updateStartDate_whenStartAfterEnd_adjustsEndDate() {
        // Arrange
        let endDate = createDate(day: 10, month: 12, year: 2024)
        let newStartDate = createDate(day: 15, month: 12, year: 2024, hour: 10, minute: 30)
        
        mockViewModel.endDate = endDate
        
        // Act
        mockViewModel.updateStartDate(newStartDate)
        
        // Assert
        XCTAssertEqual(mockViewModel.startDate, newStartDate.dayStart)
        XCTAssertEqual(mockViewModel.endDate, newStartDate.dayEnd)
    }
    
    func test_updateStartDate_whenStartBeforeEnd_keepsEndDate() {
        // Arrange
        let endDate = createDate(day: 20, month: 12, year: 2024)
        let newStartDate = createDate(day: 15, month: 12, year: 2024, hour: 10, minute: 30)
        
        mockViewModel.endDate = endDate
        
        // Act
        mockViewModel.updateStartDate(newStartDate)
        
        // Assert
        XCTAssertEqual(mockViewModel.startDate, newStartDate.dayStart)
        XCTAssertEqual(mockViewModel.endDate, endDate) // Не изменился
    }
    
    // MARK: - updateEndDate Tests
    
    func test_updateEndDate_normalizeToEndOfDay() {
        // Arrange
        let dateWithTime = createDate(day: 15, month: 12, year: 2024, hour: 14, minute: 30, second: 45)
        let expectedEnd = dateWithTime.dayEnd
        
        // Act
        mockViewModel.updateEndDate(dateWithTime)
        
        // Assert
        XCTAssertEqual(mockViewModel.endDate, expectedEnd)
    }
    
    func test_updateEndDate_whenEndBeforeStart_adjustsStartDate() {
        // Arrange
        let startDate = createDate(day: 15, month: 12, year: 2024)
        let newEndDate = createDate(day: 10, month: 12, year: 2024, hour: 10, minute: 30)
        
        mockViewModel.startDate = startDate
        
        // Act
        mockViewModel.updateEndDate(newEndDate)
        
        // Assert
        XCTAssertEqual(mockViewModel.startDate, newEndDate.dayStart)
        XCTAssertEqual(mockViewModel.endDate, newEndDate.dayEnd)
    }
    
    func test_updateEndDate_whenEndAfterStart_keepsStartDate() {
        // Arrange
        let startDate = createDate(day: 10, month: 12, year: 2024)
        let newEndDate = createDate(day: 15, month: 12, year: 2024, hour: 10, minute: 30)
        
        mockViewModel.startDate = startDate
        
        // Act
        mockViewModel.updateEndDate(newEndDate)
        
        // Assert
        XCTAssertEqual(mockViewModel.startDate, startDate) // Не изменился
        XCTAssertEqual(mockViewModel.endDate, newEndDate.dayEnd)
    }
    
    // MARK: - Corner Cases
    
    func test_sameDay_startAndEndDifferentTimes() {
        // Arrange: одинаковый день, разное время
        let morningTime = createDate(day: 15, month: 12, year: 2024, hour: 9, minute: 0)
        let eveningTime = createDate(day: 15, month: 12, year: 2024, hour: 18, minute: 30)
        
        // Act
        mockViewModel.updateStartDate(morningTime)
        mockViewModel.updateEndDate(eveningTime)
        
        // Assert
        XCTAssertEqual(mockViewModel.startDate, morningTime.dayStart) // 00:00:00
        XCTAssertEqual(mockViewModel.endDate, eveningTime.dayEnd)     // следующий день 00:00:00
        XCTAssertTrue(mockViewModel.startDate < mockViewModel.endDate)
    }
    
    func test_monthBoundary() {
        // Arrange: переход через месяц
        let endOfMonth = createDate(day: 31, month: 12, year: 2024, hour: 15, minute: 45)
        let startOfNextMonth = createDate(day: 1, month: 1, year: 2025, hour: 8, minute: 15)
        
        // Act
        mockViewModel.updateStartDate(endOfMonth)
        mockViewModel.updateEndDate(startOfNextMonth)
        
        // Assert
        XCTAssertEqual(mockViewModel.startDate, endOfMonth.dayStart)
        XCTAssertEqual(mockViewModel.endDate, startOfNextMonth.dayEnd)
        XCTAssertTrue(mockViewModel.startDate < mockViewModel.endDate)
    }
    
    func test_yearBoundary() {
        // Arrange: переход через год
        let endOfYear = createDate(day: 31, month: 12, year: 2024, hour: 23, minute: 59)
        let startOfNextYear = createDate(day: 1, month: 1, year: 2025, hour: 0, minute: 1)
        
        // Act
        mockViewModel.updateStartDate(endOfYear)
        mockViewModel.updateEndDate(startOfNextYear)
        
        // Assert
        XCTAssertEqual(mockViewModel.startDate, endOfYear.dayStart)
        XCTAssertEqual(mockViewModel.endDate, startOfNextYear.dayEnd)
        XCTAssertTrue(mockViewModel.startDate < mockViewModel.endDate)
    }
    
    func test_consecutiveDateChanges() {
        // Arrange: несколько последовательных изменений
        let date1 = createDate(day: 10, month: 12, year: 2024, hour: 10)
        let date2 = createDate(day: 15, month: 12, year: 2024, hour: 15)
        let date3 = createDate(day: 5, month: 12, year: 2024, hour: 5)
        
        // Act & Assert 1
        mockViewModel.updateStartDate(date1)
        mockViewModel.updateEndDate(date2)
        XCTAssertEqual(mockViewModel.startDate, date1.dayStart)
        XCTAssertEqual(mockViewModel.endDate, date2.dayEnd)
        
        // Act & Assert 2: возвращаем к первоначальной дате
        mockViewModel.updateEndDate(date1)
        XCTAssertEqual(mockViewModel.endDate, date1.dayEnd)
        
        // Act & Assert 3: corner case - end раньше start
        mockViewModel.updateEndDate(date3)
        XCTAssertEqual(mockViewModel.startDate, date3.dayStart) // Автоматически поправился
        XCTAssertEqual(mockViewModel.endDate, date3.dayEnd)
    }
    
    // MARK: - Helper Methods
    
    private func createDate(day: Int, month: Int, year: Int, hour: Int = 0, minute: Int = 0, second: Int = 0) -> Date {
        var components = DateComponents()
        components.day = day
        components.month = month
        components.year = year
        components.hour = hour
        components.minute = minute
        components.second = second
        
        return calendar.date(from: components) ?? Date()
    }
}

// MARK: - Mock Implementation

private class MockDateRangeSelectable: DateRangeSelectable {
    var startDate: Date = Date()
    var endDate: Date = Date()
    var validateAndReloadDataCallCount = 0
    
    func validateAndReloadData() {
        validateAndReloadDataCallCount += 1
    }
} 
