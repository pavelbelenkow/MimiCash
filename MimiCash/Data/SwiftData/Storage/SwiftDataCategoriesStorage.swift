import Foundation
import SwiftData

@MainActor
final class SwiftDataCategoriesStorage: CategoriesStorage {
    
    // MARK: - Private Properties
    private let modelContext: ModelContext
    
    // MARK: - Init
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    // MARK: - CategoriesStorage Implementation
    var categories: [Category] {
        get async {
            let descriptor = FetchDescriptor<CategoryModel>()
            
            do {
                let models = try modelContext.fetch(descriptor)
                return models.map { $0.toCategory() }
            } catch {
                print("Error fetching categories: \(error)")
                return []
            }
        }
    }
    
    func get(id: Int) async -> Category? {
        let descriptor = FetchDescriptor<CategoryModel>(
            predicate: #Predicate<CategoryModel> { $0.id == id }
        )
        do {
            let models = try modelContext.fetch(descriptor)
            return models.first?.toCategory()
        } catch {
            print("Error fetching category with id \(id): \(error)")
            return nil
        }
    }
    
    func create(_ category: Category) async {
        let entity = CategoryModel(from: category)
        modelContext.insert(entity)
        
        do {
            try modelContext.save()
        } catch {
            print("Error creating category: \(error)")
        }
    }
    
    func update(_ category: Category) async {
        let categoryId = category.id
        let descriptor = FetchDescriptor<CategoryModel>(
            predicate: #Predicate<CategoryModel> { $0.id == categoryId }
        )
        do {
            let models = try modelContext.fetch(descriptor)
            if let model = models.first {
                model.name = category.name
                model.emoji = String(category.emoji)
                model.isIncome = category.isIncome == .income
                try modelContext.save()
            }
        } catch {
            print("Error updating category: \(error)")
        }
    }
    
    func delete(id: Int) async {
        let categoryId = id
        let descriptor = FetchDescriptor<CategoryModel>(
            predicate: #Predicate<CategoryModel> { $0.id == categoryId }
        )
        do {
            let models = try modelContext.fetch(descriptor)
            for model in models {
                modelContext.delete(model)
            }
            try modelContext.save()
        } catch {
            print("Error deleting category with id \(id): \(error)")
        }
    }
    
    func getCategories(for direction: Direction) async -> [Category] {
        let isIncome = direction == .income
        let descriptor = FetchDescriptor<CategoryModel>(
            predicate: #Predicate<CategoryModel> { $0.isIncome == isIncome }
        )
        do {
            let models = try modelContext.fetch(descriptor)
            return models.map { $0.toCategory() }
        } catch {
            print("Error fetching categories for direction \(direction): \(error)")
            return []
        }
    }
    
    func clear() async {
        let descriptor = FetchDescriptor<CategoryModel>()
        
        do {
            let models = try modelContext.fetch(descriptor)
            
            for model in models {
                modelContext.delete(model)
            }
            
            try modelContext.save()
        } catch {
            print("Error clearing categories: \(error)")
        }
    }
}
