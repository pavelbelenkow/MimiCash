import Foundation

// MARK: - SearchResult

struct SearchResult<T: Searchable> {
    let item: T
    let highlightRanges: [Range<String.Index>]
}
