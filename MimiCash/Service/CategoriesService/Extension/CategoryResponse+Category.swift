extension CategoryResponse {
    
    func toCategory() -> Category {
        Category(
            id: id,
            name: name,
            emoji: Character(emoji),
            isIncome: isIncome ? .income : .outcome
        )
    }
}
