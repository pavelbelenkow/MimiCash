import SwiftUI

struct CategoryRowView: View {
    
    private let textHighlighter: TextHighlighter
    let searchResult: SearchResult<Category>
    
    // MARK: - Init
    init(
        textHighlighter: TextHighlighter = SwiftUITextHighlighter(),
        searchResult: SearchResult<Category>
    ) {
        self.textHighlighter = textHighlighter
        self.searchResult = searchResult
    }
    
    var body: some View {
        HStack(spacing: Spec.categoryRowSpacing) {
            categoryIcon
            categoryName
        }
        .frame(height: Spec.categoryRowHeight)
        .listRowInsets(Spec.categoryRowInsets)
    }
}

// MARK: - Subviews

private extension CategoryRowView {
    
    var categoryIcon: some View {
        Circle()
            .fill(Color.circle)
            .frame(width: Spec.categoryIconSize, height: Spec.categoryIconSize)
            .overlay(
                Text(String(searchResult.item.emoji))
                    .font(.system(size: Spec.categoryIconFontSize))
            )
    }
    
    var categoryName: some View {
        textHighlighter.buildHighlightedText(
            searchResult.item.name,
            ranges: searchResult.highlightRanges,
            highlightColor: .accent
        )
        .font(.body)
        .foregroundColor(.primary)
    }
}

// MARK: - Spec

private enum Spec {
    static let categoryRowSpacing: CGFloat = 12
    static let categoryRowHeight: CGFloat = 44
    static let categoryIconSize: CGFloat = 22
    static let categoryIconFontSize: CGFloat = 12
    static let categoryRowInsets = EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)
}

// MARK: - Preview

#Preview {
    CategoryRowView(
        searchResult: SearchResult(
            item: Category(
                id: 1,
                name: "Продукты питания",
                emoji: "🍔",
                isIncome: .outcome
            ),
            highlightRanges: []
        )
    )
}
