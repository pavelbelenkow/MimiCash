import Foundation
import Network
import SwiftUI

// MARK: - NetworkMonitor

protocol NetworkMonitor {
    var isConnected: Bool { get }
    
    func startMonitoring()
    func stopMonitoring()
}

@Observable
final class NetworkMonitorImpl: NetworkMonitor {
    
    // MARK: - Private Properties
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")
    
    // MARK: - NetworkMonitor Properties
    private(set) var isConnected: Bool = true
    
    // MARK: - Init
    init() {
        setupMonitor()
        startMonitoring()
    }
    
    // MARK: - Deinit
    deinit {
        stopMonitoring()
    }
    
    // MARK: - Methods
    func startMonitoring() {
        monitor.start(queue: queue)
    }
    
    func stopMonitoring() {
        monitor.cancel()
    }
    
    // MARK: - Private Methods
    private func setupMonitor() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                withAnimation(.easeInOut(duration: 0.3)) {
                    self?.isConnected = path.status == .satisfied
                }
            }
        }
    }
}

// MARK: - Environment Key

private struct NetworkMonitorKey: EnvironmentKey {
    static let defaultValue: NetworkMonitor = NetworkMonitorImpl()
}

// MARK: - Environment Values Extension

extension EnvironmentValues {
    var networkMonitor: NetworkMonitor {
        get { self[NetworkMonitorKey.self] }
        set { self[NetworkMonitorKey.self] = newValue }
    }
}

// MARK: - View Extension

extension View {
    func networkMonitor(_ monitor: NetworkMonitor) -> some View {
        environment(\.networkMonitor, monitor)
    }
} 
