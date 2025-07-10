import SwiftUI

struct SortPicker: View {
    @Binding var sort: TransactionsSort

    var body: some View {
        HStack {
            Text("Сортировка")
            
            Spacer()
            
            Picker("Сортировка", selection: $sort) {
                ForEach(TransactionsSort.allCases) { sort in
                    Text(sort.rawValue)
                        .tag(sort)
                }
            }
            .labelsHidden()
            .pickerStyle(.segmented)
            .frame(maxWidth: 180)
        }
    }
}
