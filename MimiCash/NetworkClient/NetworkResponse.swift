import Foundation

// MARK: - NetworkResponse Protocol

protocol NetworkResponse {
    var statusCode: Int { get }
    var data: Data { get }
}

struct NetworkResponseImpl: NetworkResponse {
    let statusCode: Int
    let data: Data
}
