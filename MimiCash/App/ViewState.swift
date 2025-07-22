import Foundation

enum ViewState<Content> {
    case idle
    case loading
    case success(Content)
    case error(String)
}
