import Foundation

// MARK: - TransactionsService Protocol

protocol TransactionsService {
    /// Возвращает список транзакций по `id` счета за период от `startDate` до `endDate`
    func fetchTransactions(
        accountId: Int,
        from startDate: Date,
        to endDate: Date
    ) async throws -> [Transaction]
    
    /// Возвращает созданную транзакцию, переданную в аргумент `Transaction`
    func post(transaction: Transaction) async throws -> Transaction
    
    /// Возвращает обновленную транзакцию, переданную в аргумент `Transaction`
    func update(transaction: Transaction) async throws -> Transaction
    
    /// Удаляет транзакцию на основании переданного `id` транзакции
    func delete(transactionId: Int) async throws
}

final class TransactionsServiceImp: TransactionsService {
    
    private var transactions = [
        Transaction(
            id: 1,
            account: BankAccount(id: 1, name: "Основной счет", balance: 1000.00, currency: "RUB"),
            category: Category(id: 2, name: "На собачьку", emoji: "🐕", isIncome: .outcome),
            amount: 1000.00,
            transactionDate: Date(),
            comment: "Любимке"
        ),
        Transaction(
            id: 2,
            account: BankAccount(id: 1, name: "Основной счет", balance: 1000.00, currency: "RUB"),
            category: Category(id: 4, name: "Зарплата", emoji: "🤑", isIncome: .income),
            amount: 10000.00,
            transactionDate: Date(),
            comment: "Июньская зарплатка"
        )
    ]
    
    func fetchTransactions(
        accountId: Int,
        from startDate: Date,
        to endDate: Date
    ) async throws -> [Transaction] {
        transactions.filter {
            $0.account.id == accountId &&
            $0.transactionDate >= startDate &&
            $0.transactionDate <= endDate
        }
    }
    
    func post(transaction: Transaction) async throws -> Transaction {
        guard !transactions.contains(where: { $0.id == transaction.id }) else {
            throw NSError(domain: "Duplicate", code: 1)
        }
        transactions.append(transaction)
        return transaction
    }
    
    func update(transaction: Transaction) async throws -> Transaction {
        guard
            let index = transactions.firstIndex(where: { $0.id == transaction.id })
        else {
            throw NSError(domain: "NotFound", code: 404)
        }
        
        transactions[index] = transaction
        return transaction
    }
    
    func delete(transactionId: Int) async throws {
        transactions.removeAll { $0.id == transactionId }
    }
}
