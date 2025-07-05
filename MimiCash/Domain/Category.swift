/// Модель категории транзакции
struct Category: Identifiable {
    let id: Int
    let name: String
    let emoji: Character
    let isIncome: Direction
}
