import SwiftUI

@main
struct MimiCashApp: App {
    
    init() {
        setupBearerToken("YOUR_BEARER_TOKEN_HERE")
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
    
    private func setupBearerToken(_ token: String) {
        KeychainTokenStorage.shared.setToken(token)
    }
}
