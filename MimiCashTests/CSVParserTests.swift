import XCTest
@testable import MimiCash

final class CSVParserTests: XCTestCase {
    
    func test_parseCSV_multipleValidTransactions() async throws {
        let csv = """
        id,account.id,account.name,account.balance,account.currency,category.id,category.name,category.emoji,category.isIncome,amount,transactionDate,comment
        1,1,Основной счёт,1000.00,RUB,1,Зарплата,💰,true,500.00,2025-06-13T10:08:05.522Z,Зарплата за месяц
        2,1,Основной счёт,1000.00,RUB,2,Продукты,🛒,false,150.00,2025-06-12T18:00:00.000Z,Покупка продуктов в магазине
        3,2,Счет в евро,500.00,RUB,3,Кафе,☕️,false,80.50,2025-06-11T13:45:10.000Z,Кофе с другом
        """
        
        let url = try writeTempCSV(csv)
        let parser = CSVParserImp()
        let result = try await parser.parseFile(from: url)
        
        XCTAssertEqual(result.rows.count, 3)
        XCTAssertEqual(result.rows[1]["category.name"], "Продукты")
        XCTAssertEqual(result.rows[2]["comment"], "Кофе с другом")
    }
    
    func test_parseCSV_withHeaderNotOnFirstLine() async throws {
        let csv = """
        ,,,,,,,,,,,
        garbage,line,with,junk,values,,,,,,
        id,account.id,account.name,account.balance,account.currency,category.id,category.name,category.emoji,category.isIncome,amount,transactionDate,comment
        1,1,Основной счёт,1000.00,RUB,1,Зарплата,💰,true,500.00,2025-06-13T10:08:05.522Z,Зарплата за месяц
        """
        
        let url = try writeTempCSV(csv)
        let parser = CSVParserImp()
        let result = try await parser.parseFile(from: url)
        
        XCTAssertEqual(result.rows.count, 1)
        XCTAssertEqual(result.rows[0]["account.name"], "Основной счёт")
    }
    
    func test_parseCSV_emptyLinesAreSkipped() async throws {
        let csv = """
        id,account.name

        1,Основной счёт

        2,Доллары США

        """
        let url = try writeTempCSV(csv)
        let parser = CSVParserImp()
        let result = try await parser.parseFile(from: url)

        XCTAssertEqual(result.rows.count, 2)
        XCTAssertEqual(result.rows[1]["account.name"], "Доллары США")
    }
    
    func test_parseCSV_trimsWhitespaceInUnquotedFields() async throws {
        let csv = """
        id,account.name
        1, Основной счёт
        2, Доллары США  
        """
        let url = try writeTempCSV(csv)
        let parser = CSVParserImp()
        let result = try await parser.parseFile(from: url)

        XCTAssertEqual(result.rows[0]["account.name"], "Основной счёт")
        XCTAssertEqual(result.rows[1]["account.name"], "Доллары США")
    }
    
    func test_parseCSV_handlesCRLFTermination() async throws {
        let csv = "id,account.name\r\n1,Основной счёт\r\n2,Доллары США\r\n"
        let url = try writeTempCSV(csv)
        let parser = CSVParserImp()
        let result = try await parser.parseFile(from: url)

        XCTAssertEqual(result.rows.count, 2)
        XCTAssertEqual(result.rows[1]["account.name"], "Доллары США")
    }
    
    private func writeTempCSV(_ content: String) throws -> URL {
        let tempDir = FileManager.default.temporaryDirectory
        let fileURL = tempDir.appendingPathComponent(UUID().uuidString).appendingPathExtension("csv")
        try content.write(to: fileURL, atomically: true, encoding: .utf8)
        return fileURL
    }
}
