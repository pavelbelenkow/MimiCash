import Foundation

struct CreateTransactionRequest: NetworkRequest {
    let path: String = "/transactions"
    let method: HTTPMethod = .post
    var body: Encodable?
    
    init(body: TransactionRequestBody) {
        self.body = body
    }
}
