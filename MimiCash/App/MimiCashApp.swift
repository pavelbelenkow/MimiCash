import SwiftUI
import SwiftData

@main
struct MimiCashApp: App {
    
    @State private var networkMonitor = NetworkMonitorImpl.shared
    
    init() {
        setupBearerToken("YOUR_BEARER_TOKEN_HERE")
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .networkMonitor(networkMonitor)
                .offlineIndicator()
        }
        .modelContainer(AppModelContainer.shared.getModelContainer())
    }
    
    private func setupBearerToken(_ token: String) {
        KeychainTokenStorage.shared.setToken(token)
    }
}
