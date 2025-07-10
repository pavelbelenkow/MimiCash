import SwiftUI

struct TabBarView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Binding var selectedTab: Tab
    
    var body: some View {
        TabView(selection: $selectedTab) {
            ForEach(Tab.allCases, id: \.self) { tab in
                tab.makeView()
                    .tabItem {
                        VStack {
                            Image(tab.icon)
                                .renderingMode(.template)
                            Text(tab.label)
                        }
                    }
                    .tag(tab)
            }
            .toolbarBackground(colorScheme == .dark ? .black : .white, for: .tabBar)
            .toolbarBackground(.visible, for: .tabBar)
        }
    }
}

// MARK: - Subviews

private extension Tab {
    
    @ViewBuilder
    func makeView() -> some View {
        switch self {
        case .outcomes:
            TransactionsListView(
                viewModel: TransactionsListViewModelImp(direction: .outcome)
            )
        case .incomes:
            TransactionsListView(
                viewModel: TransactionsListViewModelImp(direction: .income)
            )
        case .account:
            BankAccountView(
                viewModel: BankAccountViewModelImp()
            )
        case .categories:
            CategoriesView(
                viewModel: CategoriesViewModelImp()
            )
        case .settings:
            Text(Tab.settings.label)
        }
    }
}

#Preview {
    TabBarView(
        selectedTab: .constant(.outcomes)
    )
}
