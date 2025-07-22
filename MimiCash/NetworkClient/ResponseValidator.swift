import Foundation

// MARK: - ResponseValidator Protocol

protocol ResponseValidator {
    func validate(_ response: NetworkResponse) throws
}

extension ResponseValidator {
    func validate(_ response: NetworkResponse) throws {
        switch response.statusCode {
        case 200...299:
            return
        case 401:
            throw NetworkError.unauthorized
        case 403:
            throw NetworkError.httpError(403)
        case 404:
            throw NetworkError.notFound
        case 409:
            throw NetworkError.conflict
        case 422:
            throw NetworkError.httpError(422)
        case 429:
            throw NetworkError.httpError(429)
        case 400...499:
            throw NetworkError.httpError(response.statusCode)
        case 500...599:
            throw NetworkError.serverError(response.statusCode)
        default:
            throw NetworkError.httpError(response.statusCode)
        }
    }
}

// MARK: - Default Response Validator

struct DefaultResponseValidator: ResponseValidator {}
