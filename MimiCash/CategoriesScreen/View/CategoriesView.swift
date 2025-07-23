import SwiftUI

struct CategoriesView: View {
    
    @State private var viewModel: CategoriesViewModel
    
    // MARK: - Init
    init(viewModel: CategoriesViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        NavigationStack {
            EntityView(
                state: viewModel.viewState,
                title: Spec.title,
                content: CategoriesListView.init
            )
        }
        .tint(.navBar)
        .searchable(text: $viewModel.searchText)
        .task { await viewModel.loadCategories() }
    }
}

// MARK: - Spec

private enum Spec {
    static let title = "Мои статьи"
}

// MARK: - Preview

#Preview {
    @Previewable @Environment(\.diContainer) var diContainer
    CategoriesView(
        viewModel: CategoriesViewModelImp(
            categoriesService: diContainer.categoriesService
        )
    )
}
