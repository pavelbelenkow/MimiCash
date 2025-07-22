import SwiftUI

struct SpoilerView: UIViewRepresentable {
    let isOn: Bool
    
    func makeUIView(context: Context) -> EmitterView {
        let emitterView = EmitterView()
        
        let emitterCell = CAEmitterCell()
        emitterCell.contents = UIImage(named: "pixelDot")?.cgImage
        emitterCell.color = UIColor.navBar.cgColor
        emitterCell.contentsScale = 1.8
        emitterCell.emissionRange = .pi * 2
        emitterCell.lifetime = 1
        emitterCell.scale = 2
        emitterCell.velocityRange = 20
        emitterCell.alphaRange = 1
        emitterCell.birthRate = 500
        
        emitterView.layer.emitterShape = .rectangle
        emitterView.layer.emitterCells = [emitterCell]
        
        return emitterView
    }
    
    func updateUIView(_ uiView: EmitterView, context: Context) {
        if isOn {
            uiView.layer.beginTime = CACurrentMediaTime()
        }
        uiView.layer.birthRate = isOn ? 1 : 0
    }
}
