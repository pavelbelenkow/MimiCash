struct TransactionRequestBody: Codable {
    let accountId: Int
    let categoryId: Int
    let amount: String
    let transactionDate: String
    let comment: String?
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.accountId, forKey: .accountId)
        try container.encode(self.categoryId, forKey: .categoryId)
        try container.encode(self.amount, forKey: .amount)
        try container.encode(self.transactionDate, forKey: .transactionDate)
        
        if let comment {
            try container.encode(comment, forKey: .comment)
        } else {
            try container.encodeNil(forKey: .comment)
        }
    }
}
