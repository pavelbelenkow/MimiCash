extension Transaction {
    
    func toTransactionModel() -> TransactionModel {
        TransactionModel(from: self)
    }
}
