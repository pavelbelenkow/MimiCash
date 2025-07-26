import UIKit

/// Отрисовщик круговой диаграммы
public class PieChartRingRenderer {
    
    // MARK: - Private Constants
    
    private enum Constants {
        static let startAngle: CGFloat = -.pi / 2 // Начинаем с верхней точки
    }
    
    /// Отрисовывает круговую диаграмму
    /// - Parameters:
    ///   - context: Контекст отрисовки
    ///   - center: Центр диаграммы
    ///   - outerRadius: Внешний радиус
    ///   - innerRadius: Внутренний радиус
    ///   - entities: Данные для отрисовки
    ///   - totalValue: Общая сумма
    public func drawRing(
        in context: CGContext,
        center: CGPoint,
        outerRadius: CGFloat,
        innerRadius: CGFloat,
        entities: [PieChartEntity],
        totalValue: Decimal
    ) {
        guard !entities.isEmpty, outerRadius > innerRadius, totalValue > 0 else { return }
        
        var startAngle: CGFloat = Constants.startAngle
        
        for (index, entity) in entities.enumerated() {
            let percentage = totalValue > 0 ? Double(truncating: entity.value as NSDecimalNumber) / Double(truncating: totalValue as NSDecimalNumber) : 0
            let endAngle = startAngle + CGFloat(percentage * 2 * Double.pi)
            
            drawDonutSegment(
                center: center,
                outerRadius: outerRadius,
                innerRadius: innerRadius,
                startAngle: startAngle,
                endAngle: endAngle,
                color: PieChartColors.color(for: index),
                context: context
            )
            
            startAngle = endAngle
        }
    }
    
    /// Отрисовывает сегмент кольца
    /// - Parameters:
    ///   - center: Центр
    ///   - outerRadius: Внешний радиус
    ///   - innerRadius: Внутренний радиус
    ///   - startAngle: Начальный угол
    ///   - endAngle: Конечный угол
    ///   - color: Цвет сегмента
    ///   - context: Контекст отрисовки
    private func drawDonutSegment(
        center: CGPoint,
        outerRadius: CGFloat,
        innerRadius: CGFloat,
        startAngle: CGFloat,
        endAngle: CGFloat,
        color: UIColor,
        context: CGContext
    ) {
        let path = UIBezierPath()
        
        // Внешняя дуга
        path.addArc(
            withCenter: center,
            radius: outerRadius,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: true
        )
        
        // Внутренняя дуга (в обратном направлении)
        path.addArc(
            withCenter: center,
            radius: innerRadius,
            startAngle: endAngle,
            endAngle: startAngle,
            clockwise: false
        )
        
        path.close()
        
        color.setFill()
        path.fill()
    }
}
