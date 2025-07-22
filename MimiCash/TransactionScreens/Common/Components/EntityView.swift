import SwiftUI

struct EntityView<Content, Output>: View where Content: View {
    
    // MARK: - Properties
    let state: ViewState<Output>
    let title: String
    let loadingText: String
    let errorPrefix: String
    let content: (Output) -> Content
    
    // MARK: - Init
    init(
        state: ViewState<Output>,
        title: String,
        loadingText: String = Spec.loadingText,
        errorPrefix: String = Spec.errorPrefix,
        content: @escaping (Output) -> Content
    ) {
        self.state = state
        self.title = title
        self.loadingText = loadingText
        self.errorPrefix = errorPrefix
        self.content = content
    }
    
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

// MARK: - Spec

private enum Spec {
    static let loadingText = "Загружаемся..."
    static let errorPrefix = "Ошибка: "
}
