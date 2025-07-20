import Foundation

/// Модель данных для сегмента круговой диаграммы
public struct PieChartEntity: Equatable {
    /// Значение сегмента
    public let value: Decimal
    /// Подпись сегмента
    public let label: String
    
    public init(value: Decimal, label: String) {
        self.value = max(0, value)
        self.label = label.isEmpty ? "Без названия" : label
    }
}
