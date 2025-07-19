import Foundation

struct CategoryResponse: Decodable {
    let id: Int
    let name: String
    let emoji: String
    let isIncome: Bool
}
