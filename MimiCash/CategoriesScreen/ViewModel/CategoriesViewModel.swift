import Foundation

// MARK: - CategoriesViewModel Protocol

protocol CategoriesViewModel {
    var viewState: ViewState<[SearchResult<Category>]> { get }
    var searchText: String { get set }
    
    func loadCategories() async
}

@Observable
final class CategoriesViewModelImp: CategoriesViewModel, CategoriesProvider {
    
    // MARK: - Private Properties
    private let searchEngine: SearchEngine
    private var searchTask: Task<Void, Never>?
    private var allCategories: [Category] = []
    
    // MARK: - CategoriesProvider Properties
    let categoriesService: CategoriesService
    
    // MARK: - Properties
    var viewState: ViewState<[SearchResult<Category>]>
    var searchText = "" {
        didSet {
            searchTask?.cancel()
            searchTask = Task {
                await performSearch()
            }
        }
    }
    
    // MARK: - Init
    init(
        categoriesService: CategoriesService,
        searchEngine: SearchEngine = FuzzySearchEngine(),
        viewState: ViewState<[SearchResult<Category>]> = .idle
    ) {
        self.categoriesService = categoriesService
        self.searchEngine = searchEngine
        self.viewState = viewState
    }
    
    // MARK: - Deinit
    deinit {
        searchTask?.cancel()
    }
    
    // MARK: - Methods
    @MainActor
    func loadCategories() async {
        viewState = .loading
        
        do {
            allCategories = try await fetchAllCategories()
            await performSearch()
        } catch {
            viewState = .error(error.localizedDescription)
        }
    }
    
    // MARK: - Private Methods
    private func performSearch() async {
        let currentQuery = searchText
        let searchResults = await searchEngine.search(allCategories, query: currentQuery)
        
        guard !Task.isCancelled else { return }
        
        await MainActor.run {
            guard currentQuery == searchText else { return }
            viewState = .success(searchResults)
        }
    }
}
