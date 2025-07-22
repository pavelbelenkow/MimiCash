// MARK: - CategoriesProvider Protocol

protocol CategoriesProvider {
    var categoriesService: CategoriesService { get }
    
    func fetchAllCategories() async throws -> [Category]
    func fetchCategories(for direction: Direction) async throws -> [Category]
}

extension CategoriesProvider {
    
    func fetchAllCategories() async throws -> [Category] {
        try await categoriesService.fetchAllCategories()
    }
    
    func fetchCategories(for direction: Direction) async throws -> [Category] {
        try await categoriesService.fetchCategories(for: direction)
    }
}
