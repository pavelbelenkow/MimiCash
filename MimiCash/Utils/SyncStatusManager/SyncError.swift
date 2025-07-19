import Foundation

// MARK: - SyncError

enum SyncError: Error, LocalizedError {
    case unsyncedOperations(Int)
    case syncFailed(Error)
    case conflict(ConflictInfo)
    
    var errorDescription: String? {
        switch self {
        case .unsyncedOperations(let count):
            return "Не удалось синхронизировать \(count) операций"
        case .syncFailed(let error):
            return "Ошибка синхронизации: \(error.localizedDescription)"
        case .conflict(let conflictInfo):
            return conflictInfo.message
        }
    }
}
