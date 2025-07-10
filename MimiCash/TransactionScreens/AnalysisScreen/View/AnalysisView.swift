import SwiftUI

struct AnalysisView: UIViewControllerRepresentable {
    let viewModel: AnalysisViewModel
    
    func makeUIViewController(context: Context) -> AnalysisViewController {
        AnalysisViewController(viewModel: viewModel)
    }
    
    func updateUIViewController(_ uiViewController: AnalysisViewController, context: Context) {}
}
