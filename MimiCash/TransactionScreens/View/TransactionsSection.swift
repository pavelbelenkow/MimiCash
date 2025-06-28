import SwiftUI

struct TransactionsSection<Header: View>: View {
    let output: TransactionsOutput
    let isHistory: Bool
    @ViewBuilder let header: () -> Header
    
    var body: some View {
        List {
            Section {
                header()
                
                HStack {
                    Text(isHistory ? "Сумма" : "Всего")
                    Spacer()
                    Text(output.totalAmountFormatted())
                }
            }
            
            Section(header: Text("Операции").font(.subheadline)) {
                if !output.transactions.isEmpty {
                    ForEach(output.transactions, id: \.id) {
                        TransactionRowView(transaction: $0, isHistoryView: isHistory)
                            .frame(height: isHistory ? 60 : 44)
                            .listRowInsets(.init(top: 0, leading: 16, bottom: 0, trailing: 16))
                    }
                } else {
                    Text("Нет операций в заданном диапазоне")
                        .multilineTextAlignment(.center)
                        .padding()
                        .frame(maxWidth: .infinity)
                }
            }
        }
        .listSectionSpacing(.zero)
        .safeAreaPadding(.top)
    }
}
