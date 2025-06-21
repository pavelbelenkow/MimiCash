import DeveloperToolsSupport

enum Tab: CaseIterable, Hashable {
    case outcomes
    case incomes
    case account
    case categories
    case settings
    
    var label: String {
        switch self {
        case .outcomes:
            return "Расходы"
        case .incomes:
            return "Доходы"
        case .account:
            return "Счет"
        case .categories:
            return "Статьи"
        case .settings:
            return "Настройки"
        }
    }
    
    var icon: ImageResource {
        switch self {
        case .outcomes:
            return .downtrend
        case .incomes:
            return .uptrend
        case .account:
            return .account
        case .categories:
            return .barChart
        case .settings:
            return .settings
        }
    }
}
