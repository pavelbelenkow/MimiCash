import Foundation

// MARK: - CategoriesService Protocol

protocol CategoriesService {
    /// Возвращает список всех категорий
    func fetchAllCategories() async throws -> [Category]
    
    /// Возвращает список категорий на основании аргумента `Direction`
    func fetchCategories(for direction: Direction) async throws -> [Category]
}

final class CategoriesServiceImp: CategoriesService {
    
    // MARK: - Private Properties
    private let networkAwareService: NetworkAwareService
    private let networkClient: NetworkClient
    private let storage: CategoriesStorage
    
    // MARK: - Init
    init(
        networkAwareService: NetworkAwareService = NetworkAwareServiceImpl(),
        networkClient: NetworkClient = NetworkClientImpl(),
        storage: CategoriesStorage
    ) {
        self.networkAwareService = networkAwareService
        self.networkClient = networkClient
        self.storage = storage
    }
    
    func fetchAllCategories() async throws -> [Category] {
        return try await networkAwareService.executeWithFallback(
            networkOperation: {
                let serverCategories = try await fetchAllFromServer()
                await saveCategoriesToStorage(serverCategories)
                return serverCategories
            },
            fallbackOperation: {
                return await storage.categories
            }
        )
    }
    
    func fetchCategories(for direction: Direction) async throws -> [Category] {
        return try await networkAwareService.executeWithFallback(
            networkOperation: {
                let serverCategories = try await fetchFromServer(for: direction)
                await saveCategoriesToStorage(serverCategories)
                return serverCategories
            },
            fallbackOperation: {
                return await storage.getCategories(for: direction)
            }
        )
    }
}

private extension CategoriesServiceImp {
    
    func fetchAllFromServer() async throws -> [Category] {
        let request = GetAllCategoriesRequest()
        
        let response = try await networkClient.execute(
            request,
            responseType: [CategoryResponse].self
        )
        
        return response.map { $0.toCategory() }
    }
    
    func fetchFromServer(for direction: Direction) async throws -> [Category] {
        let request = GetCategoriesByDirectionRequest(direction: direction)
        
        let response = try await networkClient.execute(
            request,
            responseType: [CategoryResponse].self
        )
        
        return response.map { $0.toCategory() }
    }
    
    func saveCategoriesToStorage(_ categories: [Category]) async {
        let existingCategories = await storage.categories
        
        for category in categories {
            let exists = existingCategories.contains { $0.id == category.id }
            
            if exists {
                await storage.update(category)
            } else {
                await storage.create(category)
            }
        }
        
        await removeObsoleteCategories(serverCategories: categories)
    }
    
    func removeObsoleteCategories(serverCategories: [Category]) async {
        let existingCategories = await storage.categories
        let serverCategoryIds = Set(serverCategories.map { $0.id })
        
        for existingCategory in existingCategories {
            if !serverCategoryIds.contains(existingCategory.id) {
                await storage.delete(id: existingCategory.id)
            }
        }
    }
}
