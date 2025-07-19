import Foundation

// MARK: - NetworkAwareService Protocol

protocol NetworkAwareService {
    func executeWithFallback<T>(
        networkOperation: () async throws -> T,
        fallbackOperation: () async throws -> T
    ) async throws -> T
}

final class NetworkAwareServiceImpl: NetworkAwareService {
    
    // MARK: - Private Properties
    private let networkMonitor: NetworkMonitor
    
    // MARK: - Init
    init(networkMonitor: NetworkMonitor = NetworkMonitorImpl.shared) {
        self.networkMonitor = networkMonitor
    }
    
    // MARK: - NetworkAwareService
    func executeWithFallback<T>(
        networkOperation: () async throws -> T,
        fallbackOperation: () async throws -> T
    ) async throws -> T {
        
        guard networkMonitor.isConnected else {
            return try await fallbackOperation()
        }
        
        do {
            return try await networkOperation()
        } catch {
            return try await fallbackOperation()
        }
    }
}
