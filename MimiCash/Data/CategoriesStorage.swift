import Foundation

// MARK: - CategoriesStorage Protocol

protocol CategoriesStorage {
    var categories: [Category] { get async }
    func create(_ category: Category) async
    func update(_ category: Category) async
    func delete(id: Int) async
    func get(id: Int) async -> Category?
    func getCategories(for direction: Direction) async -> [Category]
    func clear() async
}
