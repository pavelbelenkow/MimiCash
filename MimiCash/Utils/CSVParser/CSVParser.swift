import Foundation

// MARK: - CSVParser Protocol

protocol CSVParser {
    func parseFile(from url: URL) async throws -> CSV
}

final class CSVParserImp: CSVParser {

    // MARK: - CSVParser
    
    func parseFile(from url: URL) async throws -> CSV {
        var header: [String]?
        var rows: [[String: String]] = []

        for try await line in url.lines {
            let fields = parseCSVLine(line)
            guard !fields.isEmpty else { continue }

            if header == nil {
                if isHeader(fields) {
                    header = fields
                    continue
                }
            }

            guard let header, fields.count == header.count else { continue }

            let row = Dictionary(uniqueKeysWithValues: zip(header, fields))
            rows.append(row)
        }

        return CSV(rows: rows)
    }
}

// MARK: - Private Methods

private extension CSVParserImp {
    
    enum ParseState {
        case outsideField
        case insideUnquotedField
        case insideQuotedField
        case quoteInQuotedField
    }
    
    func isHeader(_ fields: [String]) -> Bool {
        var seen: Set<String> = []
        for field in fields {
            if field.isEmpty || seen.contains(field) {
                return false
            }
            
            seen.insert(field)
        }
        return true
    }
    
    func parseCSVLine(_ line: String) -> [String] {
        var result: [String] = []
        var current = ""
        var state: ParseState = .outsideField
        
        for char in line {
            switch state {
            case .outsideField:
                if char == "\"" {
                    state = .insideQuotedField
                } else if char == "," {
                    result.append(current)
                    current = ""
                } else {
                    current.append(char)
                    state = .insideUnquotedField
                }
                
            case .insideUnquotedField:
                if char == "," {
                    result.append(current)
                    current = ""
                    state = .outsideField
                } else {
                    current.append(char)
                }
                
            case .insideQuotedField:
                if char == "\"" {
                    state = .quoteInQuotedField
                } else {
                    current.append(char)
                }
                
            case .quoteInQuotedField:
                if char == "\"" {
                    current.append("\"")
                    state = .insideQuotedField
                } else if char == "," {
                    result.append(current)
                    current = ""
                    state = .outsideField
                } else {
                    state = .insideUnquotedField
                    current.append(char)
                }
            }
        }
        
        result.append(current)
        return result.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
    }
}
