import Foundation

struct UpdateTransactionRequest: NetworkRequest {
    let path: String
    let method: HTTPMethod = .put
    var body: Encodable?
    
    init(transactionId: Int, body: TransactionRequestBody) {
        self.path = "/transactions/\(transactionId)"
        self.body = body
    }
}
