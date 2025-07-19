import Foundation

struct TransactionCreateResponse: Decodable {
    let id: Int
    let accountId: Int
    let categoryId: Int
    let amount: String
    let transactionDate: String
    let comment: String?
}
