/// Модель категории транзакции
struct Category: Identifiable, Hashable {
    let id: Int
    let name: String
    let emoji: Character
    let isIncome: Direction
}
