import SwiftUI

struct TransactionsSection<Header: View>: View {
    let output: TransactionsOutput
    let isHistory: Bool
    let onTransactionChanged: (() -> Void)?
    @ViewBuilder let header: () -> Header
    
    init(
        output: TransactionsOutput,
        isHistory: Bool,
        onTransactionChanged: (() -> Void)? = nil,
        @ViewBuilder header: @escaping () -> Header
    ) {
        self.output = output
        self.isHistory = isHistory
        self.onTransactionChanged = onTransactionChanged
        self.header = header
    }
    
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
                        TransactionRowView(
                            transaction: $0, 
                            isHistoryView: isHistory,
                            onTransactionChanged: onTransactionChanged
                        )
                        .frame(height: isHistory ? 60 : 44)
                        .listRowInsets(.init(top: 0, leading: 16, bottom: 0, trailing: 16))
                    }
                } else {
                    Text(isHistory ? "Нет операций в заданном диапазоне" : "Еще не было операций сегодня")
                        .foregroundStyle(.gray)
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
