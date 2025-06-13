import XCTest
@testable import MimiCash

final class TransactionJSONTests: XCTestCase {

    func test_parse_validObject_returnsTransaction() throws {
        let json = try makeValidJSONObject()
        let transaction = try XCTUnwrap(Transaction.parse(jsonObject: json))

        XCTAssertEqual(transaction.id, 1)
        XCTAssertEqual(transaction.account.name, "Основной счёт")
        XCTAssertEqual(transaction.category.isIncome, .income)
        XCTAssertEqual(transaction.amount, Decimal(string: "500.00"))
        XCTAssertEqual(transaction.comment, "Зарплата за месяц")
    }

    func test_jsonObject_roundTrip_preservesAllFields() throws {
        let original = makeValidTransaction()
        let json = original.jsonObject
        let reconstructed = try XCTUnwrap(Transaction.parse(jsonObject: json))

        XCTAssertEqual(reconstructed, original)
    }

    func test_parse_invalid_topLevel_notDictionary() {
        let json: Any = "not-a-dict"
        assertThrowsErrorEqual(
            try Transaction.parse(jsonObject: json),
            expected: .invalidTopLevelStructure
        )
    }

    func test_parse_missing_requiredField_id() throws {
        let json = try mutateJSON { $0.removeValue(forKey: "id") }
        assertThrowsErrorEqual(
            try Transaction.parse(jsonObject: json),
            expected: .missingOrInvalidField(fieldName: "id")
        )
    }

    func test_parse_invalid_account_missingFields() throws {
        let json = try mutateJSON { $0["account"] = ["id": 1] }
        assertThrowsErrorEqual(
            try Transaction.parse(jsonObject: json),
            expected: .invalidAccountFields
        )
    }
    
    func test_parse_shouldFail_onNullAccount() throws {
        let json = try mutateJSON { $0["account"] = NSNull() }

        assertThrowsErrorEqual(
            try Transaction.parse(jsonObject: json),
            expected: .missingOrInvalidField(fieldName: "account")
        )
    }

    func test_parse_invalid_category_missingFields() throws {
        let json = try mutateJSON { $0["category"] = ["id": 1] }
        assertThrowsErrorEqual(
            try Transaction.parse(jsonObject: json),
            expected: .invalidCategoryFields
        )
    }

    func test_parse_invalid_transactionDate_format() throws {
        let json = try mutateJSON { $0["transactionDate"] = "2025/06/13" }
        assertThrowsErrorEqual(
            try Transaction.parse(jsonObject: json),
            expected: .invalidDateFormat
        )
    }

    func test_parse_invalid_amount_format() throws {
        let json = try mutateJSON { $0["amount"] = "abc" }
        assertThrowsErrorEqual(
            try Transaction.parse(jsonObject: json),
            expected: .missingOrInvalidField(fieldName: "amount")
        )
    }

    func test_parse_invalid_emoji_emptyString() throws {
        let json = try mutateJSON { $0["category"] = ["emoji": ""] }
        assertThrowsErrorEqual(
            try Transaction.parse(jsonObject: json),
            expected: .invalidCategoryFields
        )
    }
    
    func test_parse_shouldIgnoreExtraFields() throws {
        let json = try mutateJSON { $0["extra_field"] = "🤷‍♂️" }

        XCTAssertNoThrow(try Transaction.parse(jsonObject: json))
    }

    // MARK: - Helpers

    private func makeValidJSONObject() throws -> Any {
        let data = """
        {
            "id": 1,
            "account": {
                "id": 1,
                "name": "Основной счёт",
                "balance": "1000.00",
                "currency": "RUB"
            },
            "category": {
                "id": 1,
                "name": "Зарплата",
                "emoji": "💰",
                "isIncome": true
            },
            "amount": "500.00",
            "transactionDate": "2025-06-12T23:04:51.942Z",
            "comment": "Зарплата за месяц"
        }
        """.data(using: .utf8)!
        return try JSONSerialization.jsonObject(with: data)
    }

    private func makeValidTransaction() -> Transaction {
        return Transaction(
            id: 1,
            account: .init(id: 1, name: "Основной счёт", balance: 1000.00, currency: "RUB"),
            category: .init(id: 1, name: "Зарплата", emoji: "💰", isIncome: .income),
            amount: 500.00,
            transactionDate: ISO8601DateFormatter.isoDateFormatter.date(from: "2025-06-12T23:04:51.942Z")!,
            comment: "Зарплата за месяц"
        )
    }
    
    private func mutateJSON(_ mutation: (inout [String: Any]) -> Void) throws -> Any {
        var json = try makeValidJSONObject() as! [String: Any]
        mutation(&json)
        return json
    }

    private func assertThrowsErrorEqual<T>(
        _ expression: @autoclosure () throws -> T,
        expected: Transaction.ParseError,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        XCTAssertThrowsError(try expression(), file: file, line: line) { error in
            guard let parseError = error as? Transaction.ParseError else {
                XCTFail("Unexpected error type: \(error)", file: file, line: line)
                return
            }
            XCTAssertEqual(parseError, expected, file: file, line: line)
        }
    }
}
