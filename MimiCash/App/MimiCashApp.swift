import SwiftUI
import SwiftData

@main
struct MimiCashApp: App {
    
    @StateObject private var diContainer = AppDIContainer()
    @State private var networkMonitor = NetworkMonitorImpl.shared
    @State private var showSplash = true
    
    init() {
        setupBearerToken("YOUR_BEARER_TOKEN_HERE")
    }
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if showSplash {
                    SplashScreen()
                        .onReceive(
                            NotificationCenter.default.publisher(for: .animationDidFinish)
                        ) { _ in
                            withAnimation(.easeInOut(duration: 0.5)) {
                                showSplash = false
                            }
                        }
                } else {
                    ContentView()
                        .environment(\.diContainer, diContainer)
                        .networkMonitor(networkMonitor)
                        .offlineIndicator()
                        .modelContainer(diContainer.modelContainer)
                        .transition(.opacity)
                }
            }
        }
    }
    
    private func setupBearerToken(_ token: String) {
        KeychainTokenStorage.shared.setToken(token)
    }
}
