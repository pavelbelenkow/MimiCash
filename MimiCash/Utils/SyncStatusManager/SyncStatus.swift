import Foundation

// MARK: - SyncStatus

enum SyncStatus: Equatable {
    case idle
    case syncing
    case completed
    case failed(ErrorEquatable)
    case conflict(ConflictInfo)
    
    static func == (lhs: SyncStatus, rhs: SyncStatus) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle): return true
        case (.syncing, .syncing): return true
        case (.completed, .completed): return true
        case (.failed(let l), .failed(let r)): return l == r
        case (.conflict(let l), .conflict(let r)): return l == r
        default: return false
        }
    }
}

struct ConflictInfo: Equatable {
    let entityId: Int
    let entityType: String
    let localVersion: String
    let serverVersion: String
    let message: String
}

// MARK: - SyncProgress

struct SyncProgress: Equatable {
    let totalOperations: Int
    let completedOperations: Int
    let currentOperation: String?
    
    var percentage: Double {
        guard totalOperations > 0 else { return 0 }
        return Double(completedOperations) / Double(totalOperations)
    }
}

// MARK: - ErrorEquatable

struct ErrorEquatable: Equatable {
    let error: Error
    
    static func == (lhs: ErrorEquatable, rhs: ErrorEquatable) -> Bool {
        return lhs.error.localizedDescription == rhs.error.localizedDescription
    }
    
    init(_ error: Error) {
        self.error = error
    }
}

// MARK: - SyncStatusObserver

protocol SyncStatusObserver: AnyObject {
    func syncStatusDidChange(_ status: SyncStatus)
    func syncProgressDidUpdate(_ progress: SyncProgress)
}
