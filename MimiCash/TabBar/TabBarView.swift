import SwiftUI

struct TabBarView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.diContainer) private var diContainer
    @Binding var selectedTab: Tab
    
    var body: some View {
        TabView(selection: $selectedTab) {
            ForEach(Tab.allCases, id: \.self) { tab in
                makeView(for: tab)
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
    
    // MARK: - Subviews
    
    @ViewBuilder
    func makeView(for tab: Tab) -> some View {
        switch tab {
        case .outcomes:
            TransactionsListView(
                viewModel: TransactionsListViewModelImp(
                    transactionsService: diContainer.transactionsService,
                    bankAccountsService: diContainer.bankAccountsService,
                    direction: .outcome
                )
            )
        case .incomes:
            TransactionsListView(
                viewModel: TransactionsListViewModelImp(
                    transactionsService: diContainer.transactionsService,
                    bankAccountsService: diContainer.bankAccountsService,
                    direction: .income
                )
            )
        case .account:
            BankAccountView(
                viewModel: BankAccountViewModelImp(
                    bankAccountsService: diContainer.bankAccountsService
                )
            )
        case .categories:
            CategoriesView(
                viewModel: CategoriesViewModelImp(
                    categoriesService: diContainer.categoriesService
                )
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
