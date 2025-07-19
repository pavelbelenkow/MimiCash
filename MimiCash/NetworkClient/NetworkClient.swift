import Foundation

// MARK: - NetworkClient Protocol

protocol NetworkClient {
    func execute<T: Decodable>(_ request: NetworkRequest, responseType: T.Type) async throws -> T
} 

final class NetworkClientImpl: NetworkClient {
    
    // MARK: - Private Properties
    private let session: URLSession
    private let requestBuilder: RequestBuilder
    private let responseValidator: ResponseValidator
    private let retryPolicy: RetryPolicy
    private let decoder: JSONDecoder
    
    // MARK: - Init
    init(
        session: URLSession = .shared,
        requestBuilder: RequestBuilder = RequestBuilderImpl(),
        responseValidator: ResponseValidator = DefaultResponseValidator(),
        retryPolicy: RetryPolicy = DefaultRetryPolicy()
    ) {
        self.session = session
        self.requestBuilder = requestBuilder
        self.responseValidator = responseValidator
        self.retryPolicy = retryPolicy
        
        self.decoder = JSONDecoder()
        self.decoder.dateDecodingStrategy = .iso8601
    }
    
    // MARK: - Methods
    func execute<T: Decodable>(_ request: NetworkRequest, responseType: T.Type) async throws -> T {
        try await performRequest(
            request,
            responseType: responseType,
            attempt: .zero
        )
    }
    
    // MARK: - Private Methods
    private func performRequest<T: Decodable>(
        _ request: NetworkRequest,
        responseType: T.Type,
        attempt: Int
    ) async throws -> T {
        let urlRequest = try requestBuilder.build(
            path: request.path,
            method: request.method,
            body: request.body
        )
        
        let (data, response) = try await session.data(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        let networkResponse = NetworkResponseImpl(statusCode: httpResponse.statusCode, data: data)
        
        // Retry logic
        if retryPolicy.shouldRetry(networkResponse, attempt: attempt) {
            try await Task.sleep(nanoseconds: UInt64(retryPolicy.delay(for: attempt) * 1_000_000_000))
            return try await performRequest(
                request,
                responseType: responseType,
                attempt: attempt + 1
            )
        }
        
        try responseValidator.validate(networkResponse)
        
        do {
            return try decoder.decode(responseType, from: data)
        } catch {
            throw NetworkError.decodingError(error)
        }
    }
}
