import Foundation

// MARK: - RetryPolicy Protocol

protocol RetryPolicy {
    func shouldRetry(_ response: NetworkResponse, attempt: Int) -> Bool
    func delay(for attempt: Int) -> TimeInterval
} 

final class DefaultRetryPolicy: RetryPolicy {
    
    // MARK: - Private Properties
    private let maxRetries = 5
    private let minDelay: TimeInterval = 2.0
    private let maxDelay: TimeInterval = 120.0
    private let factor: Double = 1.5
    private let jitter: Double = 0.05
    private let retryableStatusCodes: Set<Int> = [500, 502, 503, 504, 408, 429]
    
    // MARK: - Methods
    func shouldRetry(_ response: NetworkResponse, attempt: Int) -> Bool {
        return attempt < maxRetries && retryableStatusCodes.contains(response.statusCode)
    }
    
    func delay(for attempt: Int) -> TimeInterval {
        let baseDelay = minDelay * pow(factor, Double(attempt))
        let jitterValue = baseDelay * jitter * Double.random(in: -1...1)
        let delay = baseDelay + jitterValue
        
        return min(delay, maxDelay)
    }
}
