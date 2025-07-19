import Foundation

// MARK: - SyncStatusManager Singleton

final class SyncStatusManager: ObservableObject {
    
    // MARK: - Singleton
    static let shared = SyncStatusManager()
    
    // MARK: - Published Properties
    @Published private(set) var status: SyncStatus = .idle
    @Published private(set) var progress: SyncProgress = SyncProgress(totalOperations: 0, completedOperations: 0, currentOperation: nil)
    @Published private(set) var unsyncedOperationsCount: Int = 0
    
    // MARK: - Private Properties
    private var observers: [WeakObserver] = []
    
    // MARK: - Init
    private init() {}
    
    // MARK: - Public Methods
    func updateStatus(_ newStatus: SyncStatus) {
        DispatchQueue.main.async {
            self.status = newStatus
            self.notifyObservers { $0.syncStatusDidChange(newStatus) }
        }
    }
    
    func updateProgress(_ newProgress: SyncProgress) {
        DispatchQueue.main.async {
            self.progress = newProgress
            self.notifyObservers { $0.syncProgressDidUpdate(newProgress) }
        }
    }
    
    func updateUnsyncedCount(_ count: Int) {
        DispatchQueue.main.async {
            self.unsyncedOperationsCount = count
        }
    }
    
    func addObserver(_ observer: SyncStatusObserver) {
        observers.append(WeakObserver(observer))
        cleanupObservers()
    }
    
    func removeObserver(_ observer: SyncStatusObserver) {
        observers.removeAll { $0.observer === observer }
    }
    
    // MARK: - Private Methods
    private func notifyObservers(_ action: (SyncStatusObserver) -> Void) {
        observers.forEach { weakObserver in
            if let observer = weakObserver.observer {
                action(observer)
            }
        }
        cleanupObservers()
    }
    
    private func cleanupObservers() {
        observers.removeAll { $0.observer == nil }
    }
}

// MARK: - WeakObserver

private class WeakObserver {
    weak var observer: SyncStatusObserver?
    
    init(_ observer: SyncStatusObserver) {
        self.observer = observer
    }
} 