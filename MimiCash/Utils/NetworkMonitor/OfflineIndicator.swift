import SwiftUI

struct OfflineIndicator: View {
    
    // MARK: - Properties
    @Environment(\.networkMonitor) private var networkMonitor
    
    var body: some View {
        if !networkMonitor.isConnected {
            HStack(spacing: 8) {
                Image(systemName: "wifi.slash")
                    .foregroundColor(.white)
                    .font(.caption)
                
                Text("Offline mode")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical)
            .background(
                LinearGradient(
                    colors: [.orange, .red],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
            .opacity(networkMonitor.isConnected ? 0 : 1)
            .offset(y: networkMonitor.isConnected ? -50 : 0)
            .animation(.easeInOut(duration: 0.3), value: networkMonitor.isConnected)
        }
    }
}

// MARK: - OfflineIndicator Modifier

struct OfflineIndicatorModifier: ViewModifier {
    
    func body(content: Content) -> some View {
        VStack {
            OfflineIndicator()
            content
        }
    }
}

// MARK: - View Extension

extension View {
    
    func offlineIndicator() -> some View {
        modifier(OfflineIndicatorModifier())
    }
}
