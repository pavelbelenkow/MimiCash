import Foundation

// MARK: - CategoriesService Protocol

protocol CategoriesService {
    /// Возвращает список всех категорий
    func fetchAllCategories() async throws -> [Category]
    
    /// Возвращает список категорий на основании аргумента `Direction`
    func fetchCategories(for direction: Direction) async throws -> [Category]
}

final class CategoriesServiceImp: CategoriesService {
    
    // MARK: - Public API
    
    func fetchAllCategories() async throws -> [Category] {
        return Self.allCategories
    }
    
    func fetchCategories(for direction: Direction) async throws -> [Category] {
        return Self.allCategories.filter { $0.isIncome == direction }
    }
    
    // MARK: - Mock Data
    
    private static let allCategories: [Category] = [
        // Доходы (Income)
        Category(id: 1, name: "Зарплата", emoji: "💼", isIncome: .income),
        Category(id: 2, name: "Премия", emoji: "🏆", isIncome: .income),
        Category(id: 3, name: "Подработка", emoji: "💸", isIncome: .income),
        Category(id: 4, name: "Дивиденды", emoji: "🏦", isIncome: .income),
        Category(id: 5, name: "Проценты", emoji: "💰", isIncome: .income),
        Category(id: 6, name: "Кэшбек", emoji: "💳", isIncome: .income),
        Category(id: 7, name: "Подарок", emoji: "🎁", isIncome: .income),
        Category(id: 8, name: "Продажа", emoji: "📦", isIncome: .income),
        Category(id: 9, name: "Возврат", emoji: "↩️", isIncome: .income),
        Category(id: 10, name: "Бонус", emoji: "🎯", isIncome: .income),
        
        // Расходы (Outcome)
        Category(id: 11, name: "Продукты", emoji: "🍏", isIncome: .outcome),
        Category(id: 12, name: "Кафе", emoji: "☕️", isIncome: .outcome),
        Category(id: 13, name: "Транспорт", emoji: "🚗", isIncome: .outcome),
        Category(id: 14, name: "Квартира", emoji: "🏠", isIncome: .outcome),
        Category(id: 15, name: "Здоровье", emoji: "💊", isIncome: .outcome),
        Category(id: 16, name: "Ремонт", emoji: "🔧", isIncome: .outcome),
        Category(id: 17, name: "Мобильная связь", emoji: "📱", isIncome: .outcome),
        Category(id: 18, name: "Интернет", emoji: "🌐", isIncome: .outcome),
        Category(id: 19, name: "Одежда", emoji: "👔", isIncome: .outcome),
        Category(id: 20, name: "Развлечения", emoji: "🎬", isIncome: .outcome),
        Category(id: 21, name: "Спорт", emoji: "⚽️", isIncome: .outcome),
        Category(id: 22, name: "Образование", emoji: "📚", isIncome: .outcome),
        Category(id: 23, name: "Путешествия", emoji: "✈️", isIncome: .outcome),
        Category(id: 24, name: "Техника", emoji: "🖥️", isIncome: .outcome),
        Category(id: 25, name: "Питомцы", emoji: "🐕", isIncome: .outcome),
        Category(id: 26, name: "Красота", emoji: "💄", isIncome: .outcome),
        Category(id: 27, name: "Книги", emoji: "📖", isIncome: .outcome),
        Category(id: 28, name: "Музыка", emoji: "🎵", isIncome: .outcome),
        Category(id: 29, name: "Игры", emoji: "🎮", isIncome: .outcome),
        Category(id: 30, name: "Благотворительность", emoji: "🙏", isIncome: .outcome),
        Category(id: 31, name: "Штраф", emoji: "🚨", isIncome: .outcome),
        Category(id: 32, name: "Наличные", emoji: "💵", isIncome: .outcome),
        Category(id: 33, name: "Перевод", emoji: "💳", isIncome: .outcome),
        Category(id: 34, name: "Инвестиции", emoji: "📈", isIncome: .outcome),
        Category(id: 35, name: "Другое", emoji: "🤷‍♂️", isIncome: .outcome)
    ]
}
