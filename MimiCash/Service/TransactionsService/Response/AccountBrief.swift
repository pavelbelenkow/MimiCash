import Foundation

struct AccountBrief: Decodable {
    let id: Int
    let name: String
    let balance: String
    let currency: String
}
