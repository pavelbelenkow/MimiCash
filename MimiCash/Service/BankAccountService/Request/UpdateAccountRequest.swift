import Foundation

struct AccountUpdateBody: Codable {
    let name: String
    let balance: String
    let currency: String
}

struct UpdateAccountRequest: NetworkRequest {
    let path: String
    let method: HTTPMethod = .put
    var body: Encodable?
    
    init(accountId: Int, body: AccountUpdateBody) {
        self.path = "/accounts/\(accountId)"
        self.body = body
    }
}
