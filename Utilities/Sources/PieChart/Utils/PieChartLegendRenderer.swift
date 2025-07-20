import UIKit

/// Отрисовщик легенды для круговой диаграммы
public class PieChartLegendRenderer {
    
    private let configuration: PieChartConfiguration
    
    // MARK: - Private Constants
    private enum Constants {
        static let circleSpacing: CGFloat = 8
        static let textWidthRatio: CGFloat = 0.6
        static let heightRatio: CGFloat = 0.8
    }
    
    public init(configuration: PieChartConfiguration) {
        self.configuration = configuration
    }
    
    /// Информация о макете легенды
    public struct LegendLayout {
        let outerRadius: CGFloat
        let innerRadius: CGFloat
        let legendFont: UIFont
        let circleSize: CGFloat
        let lineSpacing: CGFloat
        let textStartX: CGFloat
        let maxTextWidth: CGFloat
        let legendHeight: CGFloat
        let legendWidth: CGFloat
    }
    
    /// Вычисляет макет легенды
    /// - Parameters:
    ///   - rect: Область отрисовки
    ///   - center: Центр диаграммы
    ///   - maxRadius: Максимальный радиус
    ///   - entities: Данные для легенды
    /// - Returns: Информация о макете
    public func calculateLayout(
        in rect: CGRect,
        center: CGPoint,
        maxRadius: CGFloat,
        entities: [PieChartEntity]
    ) -> LegendLayout {
        let (optimalFontSize, maxTextWidth, _) = calculateOptimalFontSize(for: entities, maxRadius: maxRadius)
        let legendFont = UIFont.systemFont(ofSize: optimalFontSize)
        
        let legendHeight = CGFloat(entities.count) * configuration.lineSpacing
        let legendWidth = configuration.circleSize + Constants.circleSpacing + maxTextWidth
        
        let minInnerRadiusForHeight = legendHeight / 2 + configuration.minPadding
        let minInnerRadiusForWidth = legendWidth / 2 + configuration.minPadding
        let minInnerRadius = max(minInnerRadiusForHeight, minInnerRadiusForWidth)
        let innerRadius = min(minInnerRadius, maxRadius * configuration.maxInnerRadiusRatio)
        
        let ringThickness = maxRadius * configuration.ringThicknessRatio
        let outerRadius = min(innerRadius + ringThickness, maxRadius)
        
        let textStartX = center.x - innerRadius * Constants.textWidthRatio + configuration.circleSize + Constants.circleSpacing
        
        return LegendLayout(
            outerRadius: outerRadius,
            innerRadius: innerRadius,
            legendFont: legendFont,
            circleSize: configuration.circleSize,
            lineSpacing: configuration.lineSpacing,
            textStartX: textStartX,
            maxTextWidth: maxTextWidth,
            legendHeight: legendHeight,
            legendWidth: legendWidth
        )
    }
    
    /// Отрисовывает легенду
    /// - Parameters:
    ///   - context: Контекст отрисовки
    ///   - rect: Область отрисовки
    ///   - center: Центр диаграммы
    ///   - layout: Информация о макете
    ///   - entities: Данные для легенды
    ///   - totalValue: Общая сумма
    public func drawLegend(
        in context: CGContext,
        rect: CGRect,
        center: CGPoint,
        layout: LegendLayout,
        entities: [PieChartEntity],
        totalValue: Decimal
    ) {
        guard !entities.isEmpty, totalValue > 0 else { return }
        
        let legendColor = UIColor.label
        let startY = center.y - layout.legendHeight / 2
        
        for (index, entity) in entities.enumerated() {
            let percentage = totalValue > 0 ? entity.value / totalValue : 0
            let percentageText = percentage.formattedAsPercent()
            
            let lines = splitTextIntoLines(
                entity.label,
                percentageText: percentageText,
                font: layout.legendFont,
                maxWidth: layout.innerRadius * configuration.maxTextWidthRatio
            )
            
            let y = startY + CGFloat(index) * layout.lineSpacing
            
            // Рисуем цветной кружок
            let circlePath = UIBezierPath(ovalIn: CGRect(
                x: center.x - layout.innerRadius * Constants.textWidthRatio,
                y: y - layout.circleSize / 2,
                width: layout.circleSize,
                height: layout.circleSize
            ))
            PieChartColors.color(for: index).setFill()
            circlePath.fill()
            
            // Рисуем многострочный текст
            let textAttributes: [NSAttributedString.Key: Any] = [
                .font: layout.legendFont,
                .foregroundColor: legendColor
            ]
            
            var lineY = y - (CGFloat(lines.count) * layout.legendFont.lineHeight) / 2
            
            for line in lines {
                let textSize = line.size(withAttributes: textAttributes)
                let textRect = CGRect(
                    x: layout.textStartX,
                    y: lineY,
                    width: textSize.width,
                    height: textSize.height
                )
                
                line.draw(in: textRect, withAttributes: textAttributes)
                lineY += layout.legendFont.lineHeight
            }
        }
    }
    
    // MARK: - Private Methods
    private func calculateOptimalFontSize(
        for entities: [PieChartEntity],
        maxRadius: CGFloat
    ) -> (fontSize: CGFloat, maxTextWidth: CGFloat, maxLines: Int) {
        let baseFont = UIFont.systemFont(ofSize: configuration.baseFontSize)
        let (maxTextWidth, maxLines) = calculateTextMetrics(for: entities, font: baseFont, maxRadius: maxRadius)
        
        let availableWidth = maxRadius * configuration.maxTextWidthRatio
        let availableHeight = maxRadius * Constants.heightRatio
        
        var optimalFontSize = configuration.baseFontSize
        
        // Корректируем размер шрифта по ширине
        if maxTextWidth > availableWidth {
            let scaleFactor = availableWidth / maxTextWidth
            optimalFontSize = max(configuration.minFontSize, configuration.baseFontSize * scaleFactor)
        }
        
        // Корректируем размер шрифта по высоте
        let estimatedLegendHeight = CGFloat(entities.count) * configuration.lineSpacing
        if estimatedLegendHeight > availableHeight {
            let scaleFactor = availableHeight / estimatedLegendHeight
            optimalFontSize = max(configuration.minFontSize, optimalFontSize * scaleFactor)
        }
        
        // Пересчитываем метрики с финальным размером шрифта
        let finalFont = UIFont.systemFont(ofSize: optimalFontSize)
        let (finalMaxTextWidth, _) = calculateTextMetrics(for: entities, font: finalFont, maxRadius: maxRadius)
        
        return (optimalFontSize, finalMaxTextWidth, maxLines)
    }
    
    private func calculateTextMetrics(
        for entities: [PieChartEntity],
        font: UIFont,
        maxRadius: CGFloat
    ) -> (maxTextWidth: CGFloat, maxLines: Int) {
        var maxTextWidth: CGFloat = 0
        var maxLines: Int = 1
        
        for entity in entities {
            let percentage = entity.value > 0 ? entity.value / entities.reduce(.zero) { $0 + $1.value } : 0
            let percentageText = percentage.formattedAsPercent()
            
            let lines = splitTextIntoLines(
                entity.label,
                percentageText: percentageText,
                font: font,
                maxWidth: maxRadius * configuration.maxTextWidthRatio
            )
            
            for line in lines {
                let textSize = (line as NSString).size(withAttributes: [.font: font])
                maxTextWidth = max(maxTextWidth, textSize.width)
            }
            
            maxLines = max(maxLines, lines.count)
        }
        
        return (maxTextWidth, maxLines)
    }
    
    private func splitTextIntoLines(
        _ text: String,
        percentageText: String,
        font: UIFont,
        maxWidth: CGFloat
    ) -> [String] {
        let words = text.components(separatedBy: " ")
        var lines: [String] = []
        var currentLine = percentageText
        
        for word in words {
            let testLine = currentLine.isEmpty ? word : "\(currentLine) \(word)"
            let testSize = (testLine as NSString).size(withAttributes: [.font: font])
            
            if testSize.width > maxWidth {
                if !currentLine.isEmpty && currentLine != percentageText {
                    lines.append(currentLine)
                    currentLine = word
                } else {
                    lines.append(testLine)
                    currentLine = ""
                }
            } else {
                currentLine = testLine
            }
        }
        
        if !currentLine.isEmpty {
            lines.append(currentLine)
        }
        
        return lines
    }
}
