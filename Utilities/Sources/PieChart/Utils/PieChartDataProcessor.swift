import Foundation

/// Обработчик данных для круговой диаграммы
public class PieChartDataProcessor {
    
    private let configuration: PieChartConfiguration
    
    public init(configuration: PieChartConfiguration) {
        self.configuration = configuration
    }
    
    /// Обрабатывает данные для отображения
    /// - Parameter entities: Исходные данные
    /// - Returns: Обработанные данные для отображения
    public func processEntities(_ entities: [PieChartEntity]) -> [PieChartEntity] {
        guard !entities.isEmpty else { return [] }
        
        let validEntities = entities.filter { $0.value > 0 }
        guard !validEntities.isEmpty else { return [] }
        
        let sortedEntities = validEntities.sorted { $0.value > $1.value }
        let topEntities = Array(sortedEntities.prefix(configuration.maxSegments))
        let remainingEntities = Array(sortedEntities.dropFirst(configuration.maxSegments))
        let remainingValue = remainingEntities.reduce(.zero) { $0 + $1.value }
        
        var result = topEntities
        
        if remainingValue > 0 {
            let remainingEntity = PieChartEntity(
                value: remainingValue,
                label: configuration.othersLabel
            )
            result.append(remainingEntity)
        }
        
        return result
    }
    
    /// Вычисляет общую сумму данных значений
    /// - Parameter entities: Данные
    /// - Returns: Общая сумма
    public func calculateTotalValue(_ entities: [PieChartEntity]) -> Decimal {
        return entities.reduce(.zero) { $0 + $1.value }
    }
}
