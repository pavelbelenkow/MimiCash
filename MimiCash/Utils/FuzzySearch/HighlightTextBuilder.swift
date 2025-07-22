import SwiftUI

// MARK: - TextHighlighter Protocol

protocol TextHighlighter {
    func buildHighlightedText(
        _ text: String,
        ranges: [Range<String.Index>],
        highlightColor: Color
    ) -> Text
}

final class SwiftUITextHighlighter: TextHighlighter {
    
    // MARK: - TextHighlighter
    func buildHighlightedText(
        _ text: String,
        ranges: [Range<String.Index>],
        highlightColor: Color
    ) -> Text {
        guard !ranges.isEmpty else {
            return Text(text)
        }
        
        return assembleHighlightedText(
            text,
            ranges: ranges,
            highlightColor: highlightColor
        )
    }
    
    // MARK: - Private Methods
    private func assembleHighlightedText(
        _ text: String,
        ranges: [Range<String.Index>],
        highlightColor: Color
    ) -> Text {
        let sortedRanges = ranges.sorted { $0.lowerBound < $1.lowerBound }
        var result = Text("")
        var currentIndex = text.startIndex
        
        for range in sortedRanges {
            if currentIndex < range.lowerBound {
                result = result + Text(String(text[currentIndex..<range.lowerBound]))
            }
            
            result = result + Text(String(text[range]))
                .fontWeight(.bold)
                .foregroundColor(highlightColor)
            
            currentIndex = range.upperBound
        }
        
        if currentIndex < text.endIndex {
            result = result + Text(String(text[currentIndex..<text.endIndex]))
        }
        
        return result
    }
} 
