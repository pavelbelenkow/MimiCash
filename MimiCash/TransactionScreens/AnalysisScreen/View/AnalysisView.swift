import SwiftUI

struct AnalysisView: UIViewControllerRepresentable {
    @Environment(\.diContainer) private var diContainer
    let viewModel: AnalysisViewModel
    
    func makeUIViewController(context: Context) -> AnalysisViewController {
        AnalysisViewController(viewModel: viewModel, diContainer: diContainer)
    }
    
    func updateUIViewController(_ uiViewController: AnalysisViewController, context: Context) {}
}
