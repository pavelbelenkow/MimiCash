import Foundation

// MARK: - TextDistanceCalculator Protocol

protocol TextDistanceCalculator {
    func calculate(between firstText: String, and secondText: String) -> Int
}

final class LevenshteinDistanceCalculator: TextDistanceCalculator {
    
    // MARK: - Private Properties
    private let maxDistance: Int
    
    // MARK: - Init
    init(maxDistance: Int = 2) {
        self.maxDistance = maxDistance
    }
    
    // MARK: - Methods
    func calculate(between firstText: String, and secondText: String) -> Int {
        let firstChars = Array(firstText)
        let secondChars = Array(secondText)
        let firstLength = firstChars.count
        let secondLength = secondChars.count
        
        // Быстрые проверки
        if firstLength == 0 { return secondLength }
        if secondLength == 0 { return firstLength }
        if abs(firstLength - secondLength) > maxDistance {
            return maxDistance + 1
        }
        
        var previousRow = Array(0...secondLength)
        var currentRow = Array(repeating: 0, count: secondLength + 1)
        
        for firstIndex in 1...firstLength {
            currentRow[0] = firstIndex
            
            for secondIndex in 1...secondLength {
                let substitutionCost = firstChars[firstIndex - 1] == secondChars[secondIndex - 1] ? 0 : 1
                
                currentRow[secondIndex] = min(
                    previousRow[secondIndex] + 1,
                    currentRow[secondIndex - 1] + 1,
                    previousRow[secondIndex - 1] + substitutionCost
                )
            }
            
            guard
                let minValue = currentRow.min(),
                minValue <= maxDistance
            else {
                return maxDistance + 1
            }
            
            (previousRow, currentRow) = (currentRow, previousRow)
        }
        
        return previousRow[secondLength]
    }
}
