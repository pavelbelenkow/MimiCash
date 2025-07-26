import UIKit

/// UIView для отображения круговой диаграммы
public class PieChartView: UIView {
    
    // MARK: - Public Properties
    
    /// Данные для отображения на диаграмме
    public var entities: [PieChartEntity] = [] {
        didSet {
            if oldValue != entities {
                handleDataChange(from: oldValue, to: entities)
            }
        }
    }
    
    /// Конфигурация диаграммы
    public var configuration: PieChartConfiguration = PieChartConfiguration() {
        didSet {
            updateRenderers()
            setNeedsDisplay()
        }
    }
    
    /// Настройки анимации
    public var animationSettings: PieChartAnimation {
        return animation
    }
    
    // MARK: - Private Properties
    
    private let animation = PieChartAnimation()
    private var dataProcessor: PieChartDataProcessor!
    private var legendRenderer: PieChartLegendRenderer!
    private var ringRenderer: PieChartRingRenderer!
    
    private var processedEntities: [PieChartEntity] = []
    private var totalValue: Decimal = 0
    
    private var oldEntities: [PieChartEntity] = []
    private var newEntities: [PieChartEntity] = []
    
    // MARK: - Private Constants
    
    private enum Constants {
        static let maxRadiusRatio: CGFloat = 0.5
    }
    
    // MARK: - Init
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    // MARK: - Setup
    
    private func setupView() {
        backgroundColor = .clear
        contentMode = .redraw
        updateRenderers()
        setupAnimation()
    }
    
    private func updateRenderers() {
        dataProcessor = PieChartDataProcessor(configuration: configuration)
        legendRenderer = PieChartLegendRenderer(configuration: configuration)
        ringRenderer = PieChartRingRenderer()
    }
    
    private func setupAnimation() {
        animation.delegate = self
        animation.phaseDuration = configuration.animationPhaseDuration
    }
    
    // MARK: - Data Handling
    
    private func handleDataChange(from oldData: [PieChartEntity], to newData: [PieChartEntity]) {
        guard oldData != newData else { return }
        
        oldEntities = dataProcessor.processEntities(oldData)
        newEntities = dataProcessor.processEntities(newData)
        animation.startTransition(from: oldData, to: newData)
    }
    
    // MARK: - Drawing
    
    public override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        if animation.isAnimating {
            drawAnimatedChart(in: rect, context: context)
        } else {
            drawStaticChart(in: rect, context: context)
        }
    }
    
    private func drawStaticChart(in rect: CGRect, context: CGContext) {
        guard !entities.isEmpty, rect.width > 0, rect.height > 0 else { return }
        
        processedEntities = dataProcessor.processEntities(entities)
        totalValue = dataProcessor.calculateTotalValue(processedEntities)
        
        drawChart(in: rect, context: context, entities: processedEntities, totalValue: totalValue)
    }
    
    private func drawAnimatedChart(in rect: CGRect, context: CGContext) {
        guard rect.width > 0, rect.height > 0 else { return }
        
        let rotationAngle = animation.getRotationAngle()
        let ringAlpha = animation.getRingAlpha()
        let legendAlpha = animation.getLegendAlpha()
        
        switch animation.currentPhase {
        case .fadeOut:
            drawAnimatedPhase(in: rect, context: context, entities: oldEntities, rotationAngle: rotationAngle, ringAlpha: ringAlpha, legendAlpha: legendAlpha)
        case .fadeIn:
            drawAnimatedPhase(in: rect, context: context, entities: newEntities, rotationAngle: rotationAngle, ringAlpha: ringAlpha, legendAlpha: legendAlpha)
        case .idle:
            break
        }
    }
    
    private func drawAnimatedPhase(
        in rect: CGRect,
        context: CGContext,
        entities: [PieChartEntity],
        rotationAngle: CGFloat,
        ringAlpha: CGFloat,
        legendAlpha: CGFloat
    ) {
        guard !entities.isEmpty else { return }
        
        let totalValue = dataProcessor.calculateTotalValue(entities)
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let maxRadius = min(rect.width, rect.height) * Constants.maxRadiusRatio
        let layout = legendRenderer.calculateLayout(in: rect, center: center, maxRadius: maxRadius, entities: entities)
        
        // Рисуем кольцо с вращением и fade
        context.saveGState()
        context.translateBy(x: rect.midX, y: rect.midY)
        context.rotate(by: rotationAngle)
        context.setAlpha(ringAlpha)
        context.translateBy(x: -rect.midX, y: -rect.midY)
        
        ringRenderer.drawRing(
            in: context,
            center: center,
            outerRadius: layout.outerRadius,
            innerRadius: layout.innerRadius,
            entities: entities,
            totalValue: totalValue
        )
        context.restoreGState()
        
        // Рисуем легенду только с fade (без вращения)
        context.saveGState()
        context.setAlpha(legendAlpha)
        
        legendRenderer.drawLegend(
            in: context,
            rect: rect,
            center: center,
            layout: layout,
            entities: entities,
            totalValue: totalValue
        )
        context.restoreGState()
    }
    
    private func drawChart(in rect: CGRect, context: CGContext, entities: [PieChartEntity], totalValue: Decimal) {
        guard !entities.isEmpty, totalValue > 0 else { return }
        
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let maxRadius = min(rect.width, rect.height) * Constants.maxRadiusRatio
        
        let layout = legendRenderer.calculateLayout(in: rect, center: center, maxRadius: maxRadius, entities: entities)
        
        // Рисуем кольцо
        ringRenderer.drawRing(
            in: context,
            center: center,
            outerRadius: layout.outerRadius,
            innerRadius: layout.innerRadius,
            entities: entities,
            totalValue: totalValue
        )
        
        // Рисуем легенду
        legendRenderer.drawLegend(
            in: context,
            rect: rect,
            center: center,
            layout: layout,
            entities: entities,
            totalValue: totalValue
        )
    }
    

}

// MARK: - PieChartAnimationDelegate

extension PieChartView: PieChartAnimationDelegate {
    
    public func animationDidUpdate(progress: CGFloat, phase: PieChartAnimation.Phase) {
        setNeedsDisplay()
    }
    
    public func animationDidComplete() {
        processedEntities = newEntities
        totalValue = dataProcessor.calculateTotalValue(processedEntities)
        setNeedsDisplay()
    }
}
