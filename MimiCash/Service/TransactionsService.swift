import Foundation

// MARK: - Models

struct TransactionRequest {
    let accountId: Int
    let categoryId: Int
    let amount: String
    let transactionDate: String
    let comment: String?
}

struct TransactionCreateResponse {
    let id: Int
    let accountId: Int
    let categoryId: Int
    let amount: String
    let transactionDate: String
    let comment: String?
}

struct TransactionUpdateResponse {
    let id: Int
    let account: BankAccount
    let category: Category
    let amount: String
    let transactionDate: String
    let comment: String?
}

// MARK: - TransactionsService Protocol

protocol TransactionsService {
    /// Возвращает список транзакций по `id` счета за период от `startDate` до `endDate`
    func fetchTransactions(
        accountId: Int,
        from startDate: Date,
        to endDate: Date
    ) async throws -> [Transaction]
    
    /// Возвращает созданную транзакцию на основе запроса `TransactionRequest`
    func post(request: TransactionRequest) async throws -> Transaction
    
    /// Возвращает обновленную транзакцию на основе запроса `TransactionRequest` и `id` транзакции
    func update(transactionId: Int, request: TransactionRequest) async throws -> Transaction
    
    /// Удаляет транзакцию на основании переданного `id` транзакции
    func delete(transactionId: Int) async throws
}

final class TransactionsServiceImp: TransactionsService {
    
    private static var transactions: [Transaction] = [
        // Сегодняшние транзакции
        Transaction(
            id: 1,
            account: BankAccount(id: 1, name: "Основной счет", balance: 50000, currency: "RUB"),
            category: Category(id: 1, name: "Зарплата", emoji: "💼", isIncome: .income),
            amount: 120000,
            transactionDate: Date(),
            comment: "Майская зарплата"
        ),
        Transaction(
            id: 2,
            account: BankAccount(id: 1, name: "Основной счет", balance: 40000, currency: "RUB"),
            category: Category(id: 11, name: "Продукты", emoji: "🍏", isIncome: .outcome),
            amount: 2500.50,
            transactionDate: Date(),
            comment: "Магнит, продукты на неделю"
        ),
        Transaction(
            id: 3,
            account: BankAccount(id: 1, name: "Основной счет", balance: 37500, currency: "RUB"),
            category: Category(id: 12, name: "Кафе", emoji: "☕️", isIncome: .outcome),
            amount: 450.00,
            transactionDate: Date(),
            comment: "Кофе с коллегами"
        ),
        Transaction(
            id: 4,
            account: BankAccount(id: 1, name: "Основной счет", balance: 37050, currency: "RUB"),
            category: Category(id: 25, name: "Питомцы", emoji: "🐕", isIncome: .outcome),
            amount: 1200.00,
            transactionDate: Date(),
            comment: "Корм для собаки"
        ),
        
        // Вчерашние транзакции
        Transaction(
            id: 5,
            account: BankAccount(id: 1, name: "Основной счет", balance: 35850, currency: "RUB"),
            category: Category(id: 14, name: "Квартира", emoji: "🏠", isIncome: .outcome),
            amount: 30000.00,
            transactionDate: Date().addingTimeInterval(-3600 * 24),
            comment: "Аренда за июнь"
        ),
        Transaction(
            id: 6,
            account: BankAccount(id: 1, name: "Основной счет", balance: 5850, currency: "RUB"),
            category: Category(id: 6, name: "Кэшбек", emoji: "💳", isIncome: .income),
            amount: 150.25,
            transactionDate: Date().addingTimeInterval(-3600 * 24),
            comment: "Кэшбек с карты"
        ),
        Transaction(
            id: 7,
            account: BankAccount(id: 1, name: "Основной счет", balance: 6000, currency: "RUB"),
            category: Category(id: 17, name: "Мобильная связь", emoji: "📱", isIncome: .outcome),
            amount: 800.00,
            transactionDate: Date().addingTimeInterval(-3600 * 24),
            comment: "Пополнение МТС"
        ),
        
        // Недельные транзакции
        Transaction(
            id: 8,
            account: BankAccount(id: 1, name: "Основной счет", balance: 5200, currency: "RUB"),
            category: Category(id: 15, name: "Здоровье", emoji: "💊", isIncome: .outcome),
            amount: 1200.00,
            transactionDate: Date().addingTimeInterval(-3600 * 24 * 3),
            comment: "Аптека, витамины"
        ),
        Transaction(
            id: 9,
            account: BankAccount(id: 1, name: "Основной счет", balance: 4000, currency: "RUB"),
            category: Category(id: 20, name: "Развлечения", emoji: "🎬", isIncome: .outcome),
            amount: 1200.00,
            transactionDate: Date().addingTimeInterval(-3600 * 24 * 5),
            comment: "Кино с друзьями"
        ),
        Transaction(
            id: 10,
            account: BankAccount(id: 1, name: "Основной счет", balance: 2800, currency: "RUB"),
            category: Category(id: 2, name: "Премия", emoji: "🏆", isIncome: .income),
            amount: 25000.00,
            transactionDate: Date().addingTimeInterval(-3600 * 24 * 7),
            comment: "Премия за проект"
        ),
        
        // Месячные транзакции
        Transaction(
            id: 11,
            account: BankAccount(id: 1, name: "Основной счет", balance: 27800, currency: "RUB"),
            category: Category(id: 13, name: "Транспорт", emoji: "🚗", isIncome: .outcome),
            amount: 500.00,
            transactionDate: Date().addingTimeInterval(-3600 * 24 * 15),
            comment: "Мойка машины"
        ),
        Transaction(
            id: 12,
            account: BankAccount(id: 1, name: "Основной счет", balance: 27300, currency: "RUB"),
            category: Category(id: 22, name: "Образование", emoji: "📚", isIncome: .outcome),
            amount: 15000.00,
            transactionDate: Date().addingTimeInterval(-3600 * 24 * 20),
            comment: "Курсы по SwiftUI"
        ),
        Transaction(
            id: 13,
            account: BankAccount(id: 1, name: "Основной счет", balance: 12300, currency: "RUB"),
            category: Category(id: 4, name: "Дивиденды", emoji: "🏦", isIncome: .income),
            amount: 5000.00,
            transactionDate: Date().addingTimeInterval(-3600 * 24 * 25),
            comment: "Дивиденды по акциям"
        ),
        
        // Старые транзакции
        Transaction(
            id: 14,
            account: BankAccount(id: 1, name: "Основной счет", balance: 17300, currency: "RUB"),
            category: Category(id: 23, name: "Путешествия", emoji: "✈️", isIncome: .outcome),
            amount: 50000.00,
            transactionDate: Date().addingTimeInterval(-3600 * 24 * 45),
            comment: "Отпуск в Турции"
        ),
        Transaction(
            id: 15,
            account: BankAccount(id: 1, name: "Основной счет", balance: -32700, currency: "RUB"),
            category: Category(id: 8, name: "Продажа", emoji: "📦", isIncome: .income),
            amount: 15000.00,
            transactionDate: Date().addingTimeInterval(-3600 * 24 * 60),
            comment: "Продажа на Авито"
        ),
        Transaction(
            id: 16,
            account: BankAccount(id: 1, name: "Основной счет", balance: -17700, currency: "RUB"),
            category: Category(id: 24, name: "Техника", emoji: "🖥️", isIncome: .outcome),
            amount: 45000.00,
            transactionDate: Date().addingTimeInterval(-3600 * 24 * 90),
            comment: "Новый MacBook"
        ),
        Transaction(
            id: 17,
            account: BankAccount(id: 1, name: "Основной счет", balance: -62700, currency: "RUB"),
            category: Category(id: 5, name: "Проценты", emoji: "💰", isIncome: .income),
            amount: 250.00,
            transactionDate: Date().addingTimeInterval(-3600 * 24 * 120),
            comment: "Проценты по вкладу"
        ),
        Transaction(
            id: 18,
            account: BankAccount(id: 1, name: "Основной счет", balance: -62950, currency: "RUB"),
            category: Category(id: 30, name: "Благотворительность", emoji: "🙏", isIncome: .outcome),
            amount: 1000.00,
            transactionDate: Date().addingTimeInterval(-3600 * 24 * 150),
            comment: "Помощь приюту"
        ),
        Transaction(
            id: 19,
            account: BankAccount(id: 1, name: "Основной счет", balance: -63950, currency: "RUB"),
            category: Category(id: 31, name: "Штраф", emoji: "🚨", isIncome: .outcome),
            amount: 1500.00,
            transactionDate: Date().addingTimeInterval(-3600 * 24 * 180),
            comment: "Штраф за парковку"
        ),
        Transaction(
            id: 20,
            account: BankAccount(id: 1, name: "Основной счет", balance: -65450, currency: "RUB"),
            category: Category(id: 7, name: "Подарок", emoji: "🎁", isIncome: .income),
            amount: 5000.00,
            transactionDate: Date().addingTimeInterval(-3600 * 24 * 200),
            comment: "Подарок на день рождения"
        ),
        
        // Будущие транзакции (для тестирования)
        Transaction(
            id: 21,
            account: BankAccount(id: 1, name: "Основной счет", balance: -60450, currency: "RUB"),
            category: Category(id: 2, name: "Премия", emoji: "🏆", isIncome: .income),
            amount: 30000.00,
            transactionDate: Date().addingTimeInterval(3600 * 24 * 7),
            comment: "Премия за квартал"
        ),
        Transaction(
            id: 22,
            account: BankAccount(id: 1, name: "Основной счет", balance: -30450, currency: "RUB"),
            category: Category(id: 14, name: "Квартира", emoji: "🏠", isIncome: .outcome),
            amount: 30000.00,
            transactionDate: Date().addingTimeInterval(3600 * 24 * 15),
            comment: "Аренда за июль"
        )
    ]
    
    func fetchTransactions(
        accountId: Int,
        from startDate: Date,
        to endDate: Date
    ) async throws -> [Transaction] {
        Self.transactions.filter {
            $0.account.id == accountId &&
            $0.transactionDate >= startDate &&
            $0.transactionDate <= endDate
        }
    }
    
    func post(request: TransactionRequest) async throws -> Transaction {
        // Имитируем ответ сервера
        let response = TransactionCreateResponse(
            id: Self.transactions.count + 1,
            accountId: request.accountId,
            categoryId: request.categoryId,
            amount: request.amount,
            transactionDate: request.transactionDate,
            comment: request.comment
        )
        
        // Создаем транзакцию из ответа
        let account = Self.transactions.first { $0.account.id == response.accountId }?.account ?? 
            BankAccount(id: response.accountId, name: "Основной счет", balance: 0, currency: "RUB")
        
        let category = Self.transactions.first { $0.category.id == response.categoryId }?.category ??
            Category(id: response.categoryId, name: "Другое", emoji: "🤷‍♂️", isIncome: .outcome)
        
        let transaction = Transaction(
            id: response.id,
            account: account,
            category: category,
            amount: Decimal(string: response.amount) ?? 0,
            transactionDate: ISO8601DateFormatter.isoDateFormatter.date(from: response.transactionDate) ?? Date(),
            comment: response.comment
        )
        
        Self.transactions.append(transaction)
        return transaction
    }
    
    func update(transactionId: Int, request: TransactionRequest) async throws -> Transaction {
        guard let index = Self.transactions.firstIndex(where: { $0.id == transactionId }) else {
            throw NSError(domain: "NotFound", code: 404)
        }
        
        // Находим новую категорию по categoryId из запроса
        let newCategory = Self.transactions.first { $0.category.id == request.categoryId }?.category ??
            Category(id: request.categoryId, name: "Другое", emoji: "🤷‍♂️", isIncome: .outcome)
        
        // Имитируем ответ сервера с полными данными о транзакции
        let response = TransactionUpdateResponse(
            id: transactionId,
            account: Self.transactions[index].account,
            category: newCategory, // Используем новую категорию
            amount: request.amount,
            transactionDate: request.transactionDate,
            comment: request.comment
        )
        
        // Создаем транзакцию напрямую из ответа, так как он содержит все необходимые данные
        let transaction = Transaction(
            id: response.id,
            account: response.account,
            category: response.category,
            amount: Decimal(string: response.amount) ?? 0,
            transactionDate: ISO8601DateFormatter.isoDateFormatter.date(from: response.transactionDate) ?? Date(),
            comment: response.comment
        )
        
        Self.transactions[index] = transaction
        return transaction
    }
    
    func delete(transactionId: Int) async throws {
        Self.transactions.removeAll { $0.id == transactionId }
    }
}
