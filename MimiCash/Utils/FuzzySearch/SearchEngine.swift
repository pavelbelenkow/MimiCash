import Foundation

// MARK: - SearchEngine Protocol

protocol SearchEngine {
    func search<T: Searchable>(_ items: [T], query: String) async -> [SearchResult<T>]
}

final class FuzzySearchEngine: SearchEngine {
    
    // MARK: - Private Properties
    private let matchingStrategy: TextMatchingStrategy
    
    // MARK: - Init
    init(matchingStrategy: TextMatchingStrategy = FuzzyTextMatcher()) {
        self.matchingStrategy = matchingStrategy
    }
    
    // MARK: - SearchEngine
    func search<T: Searchable>(
        _ items: [T],
        query: String
    ) async -> [SearchResult<T>] {
        let cleanQuery = query.lowercased().trimmingCharacters(in: .whitespaces)
        
        guard !cleanQuery.isEmpty else {
            return items.map { SearchResult(item: $0, highlightRanges: []) }
        }
        
        // Выполняем поиск в background потоке с параллельной обработкой
        return await withTaskGroup(of: [SearchResult<T>].self) { group in
            let chunkSize = max(100, items.count / 4)
            
            for chunk in items.chunked(into: chunkSize) {
                group.addTask { [matchingStrategy] in
                    
                    chunk.compactMap { item in
                        let searchableText = item.searchText.lowercased()
                        
                        guard
                            let highlightRanges = matchingStrategy.findMatches(
                                in: searchableText,
                                for: cleanQuery
                            )
                        else { return nil }
                        
                        return SearchResult(
                            item: item,
                            highlightRanges: highlightRanges
                        )
                    }
                    
                }
            }
            
            var searchResults: [SearchResult<T>] = []
            
            for await chunkResults in group {
                searchResults.append(contentsOf: chunkResults)
            }
            
            return searchResults
        }
    }
}

// MARK: - Array Extension

private extension Array {
    
    func chunked(into chunkSize: Int) -> [[Element]] {
        stride(from: 0, to: count, by: chunkSize).map {
            Array(
                self[$0..<Swift.min($0 + chunkSize, count)]
            )
        }
    }
}
