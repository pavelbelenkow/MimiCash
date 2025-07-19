extension Category {
    
    func toCategoryResponse() -> CategoryResponse {
        CategoryResponse(
            id: id,
            name: name,
            emoji: String(emoji),
            isIncome: isIncome == .income
        )
    }
}
