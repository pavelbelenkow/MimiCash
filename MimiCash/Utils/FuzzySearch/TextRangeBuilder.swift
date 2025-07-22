import Foundation

// MARK: - TextRangeBuilder

final class TextRangeBuilder {
    
    func createRanges(from indices: [Int], in text: String) -> [Range<String.Index>] {
        guard !indices.isEmpty else { return [] }
        
        let textIndices = Array(text.indices)
        var ranges: [Range<String.Index>] = []
        var start = indices[0]
        var end = start
        
        // Группируем соседние индексы в непрерывные диапазоны
        for i in 1..<indices.count {
            if indices[i] == end + 1 {
                end = indices[i]
            } else {
                ranges.append(
                    createRange(
                        from: start,
                        to: end,
                        in: textIndices,
                        text: text
                    )
                )
                start = indices[i]
                end = start
            }
        }
        
        // Добавляем последний диапазон
        ranges.append(
            createRange(
                from: start,
                to: end,
                in: textIndices,
                text: text
            )
        )
        
        return ranges
    }
    
    // MARK: - Private Methods
    private func createRange(
        from start: Int, 
        to end: Int, 
        in textIndices: [String.Index], 
        text: String
    ) -> Range<String.Index> {
        let startIndex = textIndices[start]
        let endIndex = text.index(after: textIndices[end])
        return startIndex..<endIndex
    }
} 
