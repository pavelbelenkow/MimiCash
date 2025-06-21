import SwiftUI

struct TransactionDatePicker: View {
    let label: String
    @Binding var date: Date
    
    var body: some View {
        dateRow(label: label, date: $date)
    }
    
    @ViewBuilder
    private func dateRow(
        label: String,
        date: Binding<Date>
    ) -> some View {
        HStack {
            Text(label)
            
            Spacer()
            
            DatePicker(label, selection: date, displayedComponents: .date)
                .tint(.accent)
                .datePickerStyle(.compact)
                .labelsHidden()
                .overlay {
                    ZStack {
                        RoundedRectangle(cornerRadius: 6)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .foregroundStyle(.circle)
                        Text(date.wrappedValue.formatted(date: .abbreviated, time: .omitted))
                    }
                    .allowsHitTesting(false)
                }
        }
    }
}
