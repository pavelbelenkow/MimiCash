import Foundation

// MARK: - Category + Searchable

extension Category: Searchable {
    var searchText: String { name }
}
