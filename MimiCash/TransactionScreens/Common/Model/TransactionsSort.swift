enum TransactionsSort: String, CaseIterable, Identifiable {
    case date = "По дате"
    case amount = "По сумме"

    var id: String { self.rawValue }
}
