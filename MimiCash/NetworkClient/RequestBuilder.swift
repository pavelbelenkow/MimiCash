import Foundation

// MARK: - RequestBuilder Protocol

protocol RequestBuilder {
    func build(
        path: String,
        method: HTTPMethod,
        body: Encodable?
    ) throws -> URLRequest
}

final class RequestBuilderImpl: RequestBuilder {
    
    // MARK: - Private Properties
    private let baseURL: String
    private let authProvider: AuthProvider
    private let encoder: JSONEncoder
    
    // MARK: - Init
    init(
        baseURL: String = "https://shmr-finance.ru/api/v1",
        authProvider: AuthProvider = TokenAuthProvider()
    ) {
        self.baseURL = baseURL
        self.authProvider = authProvider
        
        self.encoder = JSONEncoder()
        self.encoder.dateEncodingStrategy = .iso8601
    }
    
    // MARK: - Methods
    func build(
        path: String,
        method: HTTPMethod,
        body: Encodable?
    ) throws -> URLRequest {
        guard let url = URL(string: "\(baseURL)\(path)") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Auth заголовки
        authProvider.getAuthHeaders().forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        if let body {
            do {
                request.httpBody = try encoder.encode(body)
            } catch {
                throw NetworkError.encodingError(error)
            }
        }
        
        return request
    }
}
