import SwiftUI
import Lottie

struct SplashScreen: View {
    @State private var animationFinished = false
    
    var body: some View {
        ZStack {
            Color.clear.ignoresSafeArea()
            
            LottieView(
                name: "lottie_animation",
                loopMode: .playOnce,
                onAnimationFinish: {
                    animationFinished = true
                }
            )
            .frame(width: 200, height: 200)
        }
        .onChange(of: animationFinished) { _, finished in
            if finished {
                NotificationCenter.default.post(name: .animationDidFinish, object: nil)
            }
        }
    }
}

struct LottieView: UIViewRepresentable {
    let name: String
    let loopMode: LottieLoopMode
    let onAnimationFinish: () -> Void
    
    func makeUIView(context: Context) -> LottieAnimationView {
        let animationView = LottieAnimationView(name: name)
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = loopMode
        
        animationView.play()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            onAnimationFinish()
        }
        
        return animationView
    }
    
    func updateUIView(_ uiView: LottieAnimationView, context: Context) {}
}

// MARK: - Notification

extension Notification.Name {
    static let animationDidFinish = Notification.Name("animationDidFinish")
}
