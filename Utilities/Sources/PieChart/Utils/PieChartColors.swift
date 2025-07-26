import UIKit

/// Цветовая схема для круговой диаграммы
public enum PieChartColors {
    
    /// Цвета для сегментов диаграммы (максимум 6 сегментов)
    public static let segmentColors: [UIColor] = [
        .systemBlue,
        .systemGreen,
        .systemOrange,
        .systemPurple,
        .systemTeal,
        .systemYellow
    ]
    
    /// Возвращает цвет для сегмента по индексу
    /// - Parameter index: Индекс сегмента (0-5)
    /// - Returns: Цвет для сегмента
    public static func color(for index: Int) -> UIColor {
        guard index >= 0 && index < segmentColors.count else {
            return .systemGray
        }
        return segmentColors[index]
    }
}
