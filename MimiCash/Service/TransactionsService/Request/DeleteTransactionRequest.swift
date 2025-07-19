struct DeleteTransactionRequest: NetworkRequest {
    let path: String
    let method: HTTPMethod = .delete
    
    init(transactionId: Int) {
        self.path = "/transactions/\(transactionId)"
    }
}
