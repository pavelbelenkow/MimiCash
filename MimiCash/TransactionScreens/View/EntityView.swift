import SwiftUI

struct EntityView<Content, Output>: View where Content: View {
    let state: ViewState<Output>
    let title: String
    let loadingText: String
    let emptyText: String
    let errorPrefix: String
    let content: (Output) -> Content
    
    var body: some View {
        VStack {
            switch state {
            case .idle, .loading:
                ProgressView(loadingText)
                    .frame(maxWidth: .infinity, alignment: .center)
            case let .error(message):
                Text(errorPrefix + message)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
                    .padding()
            case let .success(output):
                content(output)
            }
        }
        .navigationTitle(title)
    }
}
