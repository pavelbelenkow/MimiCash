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
                viewModel: TransactionsViewModelImp(direction: .outcome)
            )
        case .incomes:
            TransactionsListView(
                viewModel: TransactionsViewModelImp(direction: .income)
            )
        case .account:
            Text(Tab.account.label)
        case .categories:
            Text(Tab.categories.label)
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
