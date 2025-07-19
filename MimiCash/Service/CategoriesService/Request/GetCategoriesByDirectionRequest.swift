struct GetCategoriesByDirectionRequest: NetworkRequest {
    let path: String
    
    init(direction: Direction) {
        let isIncome = direction == .income
        self.path = "/categories/type/\(isIncome)"
    }
}
