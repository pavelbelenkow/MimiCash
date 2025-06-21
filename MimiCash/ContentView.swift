import SwiftUI

struct ContentView: View {
    @State private var selectedTab: Tab = .outcomes
    
    var body: some View {
        TabBarView(selectedTab: $selectedTab)
    }
}

#Preview {
    ContentView()
}
