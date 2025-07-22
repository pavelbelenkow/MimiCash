import Foundation

struct GetTransactionsRequest: NetworkRequest {
    let path: String
    
    init(
        accountId: Int,
        startDate: Date? = nil,
        endDate: Date? = nil
    ) {
        var path = "/transactions/account/\(accountId)/period"
        var queryItems: [String] = []
        
        if let startDate {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            queryItems.append("startDate=\(dateFormatter.string(from: startDate))")
        }
        
        if let endDate {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            queryItems.append("endDate=\(dateFormatter.string(from: endDate))")
        }
        
        if !queryItems.isEmpty {
            path += "?" + queryItems.joined(separator: "&")
        }
        
        self.path = path
    }
}
