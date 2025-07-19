import Foundation

// MARK: - HTTP Method

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

// MARK: - NetworkRequest Protocol

protocol NetworkRequest {
    var path: String { get }
    var method: HTTPMethod { get }
    var body: Encodable? { get }
}

// MARK: - Default Values

extension NetworkRequest {
    var method: HTTPMethod { .get }
    var body: Encodable? { nil }
}
