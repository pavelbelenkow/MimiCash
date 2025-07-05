import SwiftUI

struct CategoriesListView: View {
    
    let searchResults: [SearchResult<Category>]
    
    var body: some View {
        List {
            Section(Spec.sectionHeader) {
                if searchResults.isEmpty {
                    emptyState
                } else {
                    categoriesList
                }
            }
        }
    }
}

// MARK: - Subviews

private extension CategoriesListView {
    
    var emptyState: some View {
        Text(Spec.noResults)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
            .padding()
    }
    
    var categoriesList: some View {
        ForEach(searchResults, id: \.item.id) { searchResult in
            CategoryRowView(searchResult: searchResult)
        }
    }
}

// MARK: - Spec

private enum Spec {
    static let sectionHeader = "Статьи"
    static let noResults = "Нет статей по такому запросу"
}

// MARK: - Preview

#Preview {
    CategoriesListView(
        searchResults: [
            SearchResult(
                item: Category(
                    id: 1,
                    name: "Продукты питания",
                    emoji: "🍔",
                    isIncome: .outcome
                ),
                highlightRanges: []
            ),
            SearchResult(
                item: Category(
                    id: 2,
                    name: "Транспорт",
                    emoji: "🚗",
                    isIncome: .outcome
                ),
                highlightRanges: []
            )
        ]
    )
}
