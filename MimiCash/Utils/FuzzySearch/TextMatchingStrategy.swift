import Foundation

// MARK: - TextMatchingStrategy Protocol

protocol TextMatchingStrategy {
    func findMatches(in text: String, for query: String) -> [Range<String.Index>]?
}

final class FuzzyTextMatcher: TextMatchingStrategy {
    
    // MARK: - Dependencies
    private let distanceCalculator: TextDistanceCalculator
    private let rangeBuilder: TextRangeBuilder
    
    // MARK: - Configuration
    private let maxEditDistance: Int
    private let orderedMatchThreshold: Double
    private let anyMatchThreshold: Double
    
    // MARK: - Init
    init(
        distanceCalculator: TextDistanceCalculator = LevenshteinDistanceCalculator(),
        rangeBuilder: TextRangeBuilder = TextRangeBuilder(),
        maxEditDistance: Int = 2,
        orderedMatchThreshold: Double = 0.5,
        anyMatchThreshold: Double = 0.4
    ) {
        self.distanceCalculator = distanceCalculator
        self.rangeBuilder = rangeBuilder
        self.maxEditDistance = maxEditDistance
        self.orderedMatchThreshold = orderedMatchThreshold
        self.anyMatchThreshold = anyMatchThreshold
    }
    
    // MARK: - TextMatchingStrategy
    func findMatches(in text: String, for query: String) -> [Range<String.Index>]? {
        
        if let range = text.range(of: query) {
            return [range]
        }
        
        // Проверяем fuzzy совпадение с учетом максимального расстояния
        let distance = distanceCalculator.calculate(between: text, and: query)
        guard distance <= maxEditDistance else { return nil }
        
        // Попытка упорядоченного поиска
        if let ranges = findOrderedMatches(in: text, for: query) {
            return ranges
        }
        
        return findAnyMatches(in: text, for: query)
    }
    
    // MARK: - Private Methods
    private func findOrderedMatches(in text: String, for query: String) -> [Range<String.Index>]? {
        let textChars = Array(text)
        let queryChars = Array(query)
        
        var matchedIndices: [Int] = []
        var queryIndex = 0
        
        for (textIndex, textChar) in textChars.enumerated() {
            if queryIndex < queryChars.count && textChar == queryChars[queryIndex] {
                matchedIndices.append(textIndex)
                queryIndex += 1
            }
        }
        
        let coverage = Double(matchedIndices.count) / Double(queryChars.count)
        guard coverage >= orderedMatchThreshold else { return nil }
        
        return rangeBuilder.createRanges(from: matchedIndices, in: text)
    }
    
    private func findAnyMatches(in text: String, for query: String) -> [Range<String.Index>]? {
        let textChars = Array(text)
        let queryChars = Array(query)
        
        var matchedIndices: [Int] = []
        var usedQueryIndices: Set<Int> = []
        
        for (textIndex, textChar) in textChars.enumerated() {
            for (queryIndex, queryChar) in queryChars.enumerated() {
                if textChar == queryChar && !usedQueryIndices.contains(queryIndex) {
                    matchedIndices.append(textIndex)
                    usedQueryIndices.insert(queryIndex)
                    break
                }
            }
        }
        
        let coverage = Double(matchedIndices.count) / Double(queryChars.count)
        guard coverage >= anyMatchThreshold else { return nil }
        
        matchedIndices.sort()
        return rangeBuilder.createRanges(from: matchedIndices, in: text)
    }
}
