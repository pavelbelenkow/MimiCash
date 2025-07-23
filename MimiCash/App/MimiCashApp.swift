import SwiftUI
import SwiftData

@main
struct MimiCashApp: App {
    
    @StateObject private var diContainer = AppDIContainer()
    @State private var networkMonitor = NetworkMonitorImpl.shared
    
    init() {
        setupBearerToken("YOUR_BEARER_TOKEN_HERE")
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.diContainer, diContainer)
                .networkMonitor(networkMonitor)
                .offlineIndicator()
                .modelContainer(diContainer.modelContainer)
        }
    }
    
    private func setupBearerToken(_ token: String) {
        KeychainTokenStorage.shared.setToken(token)
    }
}
