import Foundation

// MARK: - CategoriesServiceProtocol

protocol CategoriesServiceProtocol {
    /// Возвращает список всех категорий
    func fetchAllCategories() async throws -> [Category]
    
    /// Возвращает список категорий на основании аргумента `Direction`
    func fetchCategories(for direction: Direction) async throws -> [Category]
}

final class CategoriesService: CategoriesServiceProtocol {
    
    private let categories = [
        Category(id: 1, name: "Одежда", emoji: "👔", isIncome: .outcome),
        Category(id: 2, name: "На собачьку", emoji: "🐕", isIncome: .outcome),
        Category(id: 3, name: "Продкуты", emoji: "🛒", isIncome: .outcome),
        Category(id: 4, name: "Зарплата", emoji: "🤑", isIncome: .income),
        Category(id: 5, name: "Подработка", emoji: "💸", isIncome: .income),
    ]
    
    func fetchAllCategories() async throws -> [Category] {
        categories
    }
    
    func fetchCategories(for direction: Direction) async throws -> [Category] {
        categories.filter { $0.isIncome == direction }
    }
}
