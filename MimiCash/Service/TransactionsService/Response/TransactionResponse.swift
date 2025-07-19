import Foundation

struct TransactionResponse: Decodable {
    let id: Int
    let account: AccountBrief
    let category: CategoryResponse
    let amount: String
    let transactionDate: String
    let comment: String?
}
