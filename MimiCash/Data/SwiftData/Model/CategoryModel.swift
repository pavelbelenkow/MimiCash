import Foundation
import SwiftData

@Model
final class CategoryModel {
    var id: Int
    var name: String
    var emoji: String
    var isIncome: Bool
    
    init(from category: Category) {
        self.id = category.id
        self.name = category.name
        self.emoji = String(category.emoji)
        self.isIncome = category.isIncome == .income
    }
    
    func toCategory() -> Category {
        Category(
            id: id,
            name: name,
            emoji: Character(emoji),
            isIncome: isIncome ? .income : .outcome
        )
    }
}
