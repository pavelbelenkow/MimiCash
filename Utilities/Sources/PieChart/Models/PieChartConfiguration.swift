import Foundation

/// Конфигурация круговой диаграммы
public struct PieChartConfiguration {
    
    // MARK: - Ring Settings
    
    /// Толщина кольца относительно максимального радиуса (0.1-0.2)
    public var ringThicknessRatio: CGFloat = 0.12 {
        didSet {
            ringThicknessRatio = max(0.1, min(0.2, ringThicknessRatio))
        }
    }
    
    /// Максимальный внутренний радиус относительно внешнего (0.5-0.9)
    public var maxInnerRadiusRatio: CGFloat = 0.9 {
        didSet {
            maxInnerRadiusRatio = max(0.5, min(0.9, maxInnerRadiusRatio))
        }
    }
    
    // MARK: - Legend Settings
    
    /// Минимальный отступ от края кольца до легенды
    public var minPadding: CGFloat = 20
    
    /// Максимальная ширина текста относительно внутреннего радиуса
    public var maxTextWidthRatio: CGFloat = 0.6 {
        didSet {
            maxTextWidthRatio = max(0.3, min(0.8, maxTextWidthRatio))
        }
    }
    
    /// Размер цветного кружка рядом с текстом
    public var circleSize: CGFloat = 6 {
        didSet {
            circleSize = max(4, min(12, circleSize))
        }
    }
    
    /// Межстрочный интервал между элементами легенды
    public var lineSpacing: CGFloat = 14 {
        didSet {
            lineSpacing = max(8, min(20, lineSpacing))
        }
    }
    
    /// Базовый размер шрифта
    public var baseFontSize: CGFloat = 9 {
        didSet {
            baseFontSize = max(minFontSize, min(16, baseFontSize))
        }
    }
    
    /// Минимальный размер шрифта при автоматическом масштабировании
    public var minFontSize: CGFloat = 7 {
        didSet {
            minFontSize = max(6, min(baseFontSize, minFontSize))
        }
    }
    
    // MARK: - Data Processing
    
    /// Максимальное количество отображаемых сегментов
    public var maxSegments: Int = 5 {
        didSet {
            maxSegments = max(3, min(8, maxSegments))
        }
    }
    
    /// Название для группировки остальных сегментов
    public var othersLabel: String = "Остальные" {
        didSet {
            if othersLabel.isEmpty {
                othersLabel = "Остальные"
            }
        }
    }
    
    // MARK: - Animation
    
    /// Длительность одной фазы анимации
    public var animationPhaseDuration: TimeInterval = 0.3 {
        didSet {
            animationPhaseDuration = max(0.1, min(1.0, animationPhaseDuration))
        }
    }
    
    // MARK: - Init
    public init() {}
    
    // MARK: - Preset Configurations
    
    /// Конфигурация с увеличенным пространством для легенды
    /// 
    /// Рекомендуется для случаев с большим количеством категорий или длинными названиями.
    /// - Увеличивает отступы между легендой и кольцом
    /// - Позволяет использовать больше места для текста
    /// - Увеличивает межстрочный интервал
    /// - Использует больший базовый размер шрифта
    public static let spacious = PieChartConfiguration(
        minPadding: 30,
        maxTextWidthRatio: 0.7,
        lineSpacing: 16,
        baseFontSize: 10
    )
    
    /// Конфигурация для компактного отображения
    /// 
    /// Рекомендуется для случаев с небольшим количеством коротких категорий.
    /// - Уменьшает отступы для экономии места
    /// - Ограничивает ширину текста
    /// - Уменьшает межстрочный интервал
    /// - Использует меньший базовый размер шрифта
    public static let compact = PieChartConfiguration(
        minPadding: 15,
        maxTextWidthRatio: 0.5,
        lineSpacing: 12,
        baseFontSize: 8
    )
    
    // MARK: - Private Init for Presets
    private init(
        minPadding: CGFloat,
        maxTextWidthRatio: CGFloat,
        lineSpacing: CGFloat,
        baseFontSize: CGFloat
    ) {
        self.minPadding = minPadding
        self.maxTextWidthRatio = maxTextWidthRatio
        self.lineSpacing = lineSpacing
        self.baseFontSize = baseFontSize
    }
}
