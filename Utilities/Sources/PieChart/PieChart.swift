import Foundation

/// Основной модуль для работы с круговыми диаграммами
/// 
/// Предоставляет простой API для создания и настройки круговых диаграмм с анимацией.
/// Модуль автоматически обрабатывает данные, группирует мелкие сегменты и обеспечивает
/// плавные переходы при изменении данных.
/// 
/// ## Основные возможности:
/// - Автоматическая группировка мелких сегментов в "Остальные"
/// - Плавная анимация при смене данных
/// - Адаптивный размер шрифта
/// - Настраиваемая конфигурация
/// - Поддержка многострочного текста в легенде
/// 
/// ## Примеры использования:
/// 
/// ### Базовое создание:
/// ```swift
/// let pieChartView = PieChart.createView()
/// pieChartView.entities = [
///     PieChartEntity(value: 100, label: "Категория 1"),
///     PieChartEntity(value: 200, label: "Категория 2"),
///     PieChartEntity(value: 150, label: "Категория 3")
/// ]
/// ```
/// 
/// ### С увеличенным пространством для легенды:
/// ```swift
/// let pieChartView = PieChart.createView(with: .spacious)
/// ```
/// 
/// ### С компактными настройками:
/// ```swift
/// let pieChartView = PieChart.createView(with: .compact)
/// ```
/// 
/// ### С пользовательскими настройками:
/// ```swift
/// var customConfig = PieChartConfiguration()
/// customConfig.minPadding = 25
/// customConfig.maxTextWidthRatio = 0.65
/// customConfig.lineSpacing = 15
/// customConfig.baseFontSize = 11
/// 
/// let pieChartView = PieChart.createView(with: customConfig)
/// ```
public enum PieChart {
    
    /// Создать экземпляр PieChartView
    /// - Returns: Настроенный экземпляр PieChartView
    public static func createView() -> PieChartView {
        return PieChartView()
    }
    
    /// Создать экземпляр PieChartView с конфигурацией
    /// - Parameter configuration: Конфигурация диаграммы
    /// - Returns: Настроенный экземпляр PieChartView
    public static func createView(with configuration: PieChartConfiguration) -> PieChartView {
        let view = PieChartView()
        view.configuration = configuration
        return view
    }
}
