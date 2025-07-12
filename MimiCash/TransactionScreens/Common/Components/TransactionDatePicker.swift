import SwiftUI

struct TransactionDatePicker: View {
    @Binding var date: Date
    
    let label: String
    let components: DatePickerComponents
    
    init(
        date: Binding<Date>,
        label: String,
        components: DatePickerComponents = .date
    ) {
        self._date = date
        self.label = label
        self.components = components
    }
    
    var body: some View {
        dateRow(
            label: label,
            date: $date,
            components: components
        )
    }
    
    private func dateRow(
        label: String,
        date: Binding<Date>,
        components: DatePickerComponents
    ) -> some View {
        HStack {
            Text(label)
            
            Spacer()
            
            DatePicker(
                label,
                selection: date,
                displayedComponents: components
            )
            .tint(.accent)
            .datePickerStyle(.compact)
            .labelsHidden()
            .overlay {
                ZStack {
                    RoundedRectangle(cornerRadius: 6)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .foregroundStyle(.circle)
                    
                    Text(
                        formattedText(
                            for: date.wrappedValue,
                            components: components
                        )
                    )
                }
                .allowsHitTesting(false)
            }
        }
    }
    
    private func formattedText(for value: Date, components: DatePickerComponents) -> String {
        switch components {
        case .date:
            return value.formatted(date: .abbreviated, time: .omitted)
        case .hourAndMinute:
            return value.formatted(date: .omitted, time: .shortened)
        default:
            return value.formatted(date: .abbreviated, time: .shortened)
        }
    }
}
