import SwiftUI

struct TransactionRowView: View {
    let transaction: Transaction
    let isHistoryView: Bool
    
    var body: some View {
        NavigationLink {
            EmptyView()
        } label: {
            HStack(spacing: 12) {
                if transaction.category.isIncome == .outcome {
                    ZStack {
                        Circle()
                            .fill(Color.circle)
                        Text(transaction.category.emoji.description)
                            .font(.system(size: 12))
                    }
                    .frame(width: 22, height: 22)
                }
                
                VStack(alignment: .leading) {
                    Text(transaction.category.name)
                    
                    if let comment = transaction.comment, !comment.isEmpty {
                        Text(comment)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text(transaction.amount.formatted() + " ₽")
                    
                    if isHistoryView {
                        Text(transaction.transactionDate.formatted(date: .omitted, time: .shortened))
                    }
                }
            }
            .padding(.trailing)
        }
    }
}
