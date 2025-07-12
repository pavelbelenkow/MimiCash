import Foundation

enum TransactionFormMode {
    case create(direction: Direction)
    case edit(transaction: Transaction)
}

extension TransactionFormMode {
    
    var saveButtonTitle: String {
        switch self {
        case .create:
            return "Создать"
        case .edit:
            return "Сохранить"
        }
    }
    
    var direction: Direction {
        switch self {
        case let .create(direction):
            return direction
        case let .edit(transaction):
            return transaction.category.isIncome
        }
    }
    
    var navigationTitle: String {
        direction == .income ? "Мои доходы" : "Мои расходы"
    }
    
    var deleteButtonTitle: String {
        direction == .income ? "Удалить доход" : "Удалить расход"
    }
}
