import Foundation

// MARK: - TransactionsFileCacheProtocol

protocol TransactionsFileCacheProtocol {
    /// Коллекция всех уникальных транзакций
    var transactions: [Transaction] { get async }
    
    /// Добавляет новую транзакцию. При совпадении `id` старая транзакция будет заменена
    func add(_ transaction: Transaction) async
    
    /// Удаляет транзакцию по идентификатору `id`
    func remove(id: Int) async
    
    /// Сохраняет все транзакции в файл с указанным именем в формате JSON
    func save(to filename: String) async throws
    
    /// Загружает транзакции из файла с указанным именем
    func load(from filename: String) async throws
}

actor TransactionsFileCache: TransactionsFileCacheProtocol {
    
    // MARK: - Private Properties
    private let fileManager = FileManager.default
    private var transactionSet: Set<Transaction> = []
    
    // MARK: - Properties
    var transactions: [Transaction] {
        Array(transactionSet)
    }
    
    // MARK: - Private Methods
    /// Возвращает URL файла в директории `Documents` по заданному имени
    private func fileURL(for filename: String) -> URL {
        fileManager
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(filename)
            .appendingPathExtension("json")
    }
    
    // MARK: - Methods
    func add(_ transaction: Transaction) async {
        transactionSet.insert(transaction)
    }
    
    func remove(id: Int) async {
        transactionSet.remove { $0.id == id }
    }
    
    func save(to filename: String) async throws {
        let array = transactionSet.map { $0.jsonObject }
        let data = try JSONSerialization.data(withJSONObject: array, options: [.prettyPrinted])
        try data.write(to: fileURL(for: filename), options: [.atomic])
    }
    
    func load(from filename: String) async throws {
        let url = fileURL(for: filename)
        
        guard fileManager.fileExists(atPath: url.path) else {
            transactionSet = []
            return
        }
        
        let data = try Data(contentsOf: url)
        let raw = try JSONSerialization.jsonObject(with: data) as? [Any] ?? []
        let parsed = raw.compactMap { Transaction.parse(jsonObject: $0) }
        transactionSet = Set(parsed)
    }
}

// MARK: - Set<Transaction> Extension
private extension Set where Element == Transaction {
    
    /// Удаляет первый элемент, удовлетворяющий условию
    mutating func remove(where predicate: (Transaction) -> Bool) {
        if let element = first(where: predicate) {
            remove(element)
        }
    }
}
