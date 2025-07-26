import UIKit

/// Протокол для делегата анимации круговой диаграммы
public protocol PieChartAnimationDelegate: AnyObject {
    /// Вызывается при каждом шаге анимации
    /// - Parameter progress: Прогресс анимации (0...1)
    /// - Parameter phase: Текущая фаза анимации
    func animationDidUpdate(progress: CGFloat, phase: PieChartAnimation.Phase)
    
    /// Вызывается при завершении анимации
    func animationDidComplete()
}

/// Анимация смены данных круговой диаграммы
public class PieChartAnimation {
    
    // MARK: - Public Types
    
    /// Фазы анимации
    public enum Phase {
        case idle
        case fadeOut
        case fadeIn
    }
    
    // MARK: - Public Properties
    
    /// Делегат анимации
    public weak var delegate: PieChartAnimationDelegate?
    
    /// Длительность одной фазы анимации в секундах
    public var phaseDuration: TimeInterval = 0.5
    
    /// Текущая фаза анимации
    public private(set) var currentPhase: Phase = .idle
    
    /// Прогресс текущей фазы (0...1)
    public private(set) var progress: CGFloat = 0
    
    // MARK: - Private Properties
    
    private var displayLink: CADisplayLink?
    private var startTime: CFTimeInterval = 0
    
    // MARK: - Public Methods
    
    /// Запускает анимацию перехода между старыми и новыми данными
    /// - Parameter oldData: Старые данные
    /// - Parameter newData: Новые данные
    public func startTransition(
        from oldData: [PieChartEntity],
        to newData: [PieChartEntity]
    ) {
        guard oldData != newData else { return }
        
        stopAnimation()
        currentPhase = .fadeOut
        progress = 0
        startTime = CACurrentMediaTime()
        
        displayLink = CADisplayLink(target: self, selector: #selector(handleAnimationStep))
        displayLink?.add(to: .main, forMode: .common)
        
        delegate?.animationDidUpdate(progress: progress, phase: currentPhase)
    }
    
    /// Останавливает анимацию
    public func stopAnimation() {
        displayLink?.invalidate()
        displayLink = nil
        currentPhase = .idle
        progress = 0
    }
    
    /// Возвращает текущий угол поворота для кольца
    /// - Returns: Угол в радианах
    public func getRotationAngle() -> CGFloat {
        switch currentPhase {
        case .fadeOut:
            return .pi * progress
        case .fadeIn:
            return .pi + .pi * progress
        case .idle:
            return 0
        }
    }
    
    /// Возвращает текущую прозрачность для кольца
    /// - Returns: Значение прозрачности (0...1)
    public func getRingAlpha() -> CGFloat {
        switch currentPhase {
        case .fadeOut:
            return 1 - progress
        case .fadeIn:
            return progress
        case .idle:
            return 1
        }
    }
    
    /// Возвращает текущую прозрачность для легенды
    /// - Returns: Значение прозрачности (0...1)
    public func getLegendAlpha() -> CGFloat {
        switch currentPhase {
        case .fadeOut:
            return 1 - progress
        case .fadeIn:
            return progress
        case .idle:
            return 1
        }
    }
    
    /// Проверяет, активна ли анимация
    /// - Returns: true если анимация выполняется
    public var isAnimating: Bool {
        return currentPhase != .idle
    }
    
    // MARK: - Private Methods
    @objc private func handleAnimationStep() {
        guard let displayLink = displayLink else { return }
        
        let elapsed = CACurrentMediaTime() - startTime
        progress = CGFloat(elapsed / phaseDuration)
        
        if progress >= 1.0 {
            progress = 1.0
            
            switch currentPhase {
            case .fadeOut:
                currentPhase = .fadeIn
                progress = 0
                startTime = CACurrentMediaTime()
                delegate?.animationDidUpdate(progress: progress, phase: currentPhase)
                
            case .fadeIn:
                currentPhase = .idle
                progress = 0
                displayLink.invalidate()
                self.displayLink = nil
                delegate?.animationDidComplete()
                
            case .idle:
                break
            }
        } else {
            delegate?.animationDidUpdate(progress: progress, phase: currentPhase)
        }
    }
}
