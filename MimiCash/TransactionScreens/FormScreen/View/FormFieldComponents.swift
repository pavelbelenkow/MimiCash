import SwiftUI

// MARK: - CategoryRow

struct CategoryRow: View {
    let selectedCategory: Category?
    let availableCategories: [Category]
    let onCategorySelected: (Category) -> Void
    
    var body: some View {
        HStack {
            Text("Статья")
            Spacer()
            Picker("Статья", selection: Binding(
                get: { selectedCategory },
                set: { newCategory in
                    if let category = newCategory {
                        onCategorySelected(category)
                    }
                }
            )) {
                Text("Выберите категорию")
                    .foregroundColor(.secondary)
                    .tag(nil as Category?)
                ForEach(availableCategories) { category in
                    HStack(spacing: 6) {
                        Text(category.emoji.description + " " + category.name)
                    }
                    .tag(category as Category?)
                }
            }
            .pickerStyle(.menu)
            .labelsHidden()
        }
    }
}

// MARK: - AmountRow

struct AmountRow: View {
    @Binding var amount: String
    let onAmountChange: (String) -> Void
    let isFocused: Bool
    
    @FocusState private var localFocus: Bool
    
    var body: some View {
        HStack {
            Text("Сумма")
            Spacer()
            TextField(placeholderText, text: $amount)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
                .focused($localFocus)
                .onChange(of: amount) { _, newValue in
                    let formatted = newValue.formatInput()
                    if formatted != newValue {
                        amount = formatted
                    }
                    onAmountChange(formatted)
                }
                .onChange(of: isFocused) { _, newValue in
                    localFocus = newValue
                }
        }
    }
    
    private var placeholderText: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        formatter.groupingSeparator = Locale.current.groupingSeparator
        formatter.decimalSeparator = Locale.current.decimalSeparator
        
        return formatter.string(from: NSNumber(value: 0)) ?? "0"
    }
}

// MARK: - DateRow

struct DateRow: View {
    @Binding var date: Date
    let onDateChange: (Date) -> Void
    
    var body: some View {
        TransactionDatePicker(
            date: Binding(
                get: { date },
                set: { newDate in
                    let limitedDate = min(newDate, Date())
                    date = limitedDate
                    onDateChange(limitedDate)
                }
            ),
            label: "Дата"
        )
    }
}

// MARK: - TimeRow

struct TimeRow: View {
    @Binding var time: Date
    let date: Date
    let onTimeChange: (Date) -> Void
    
    var body: some View {
        TransactionDatePicker(
            date: Binding(
                get: { time },
                set: { newTime in
                    let now = Date()
                    let calendar = Calendar.current
                    let isToday = calendar.isDate(date, inSameDayAs: now)
                    let limitedTime: Date
                    if isToday && newTime > now {
                        limitedTime = now
                    } else {
                        limitedTime = newTime
                    }
                    time = limitedTime
                    onTimeChange(limitedTime)
                }
            ),
            label: "Время",
            components: .hourAndMinute
        )
    }
}

// MARK: - CommentRow

struct CommentRow: View {
    @Binding var comment: String
    let onCommentChange: (String) -> Void
    let isFocused: Bool
    @FocusState private var localFocus: Bool
    
    var body: some View {
        TextField("Комментарий", text: $comment)
            .focused($localFocus)
            .onChange(of: comment) { _, newValue in
                onCommentChange(newValue)
            }
            .onChange(of: isFocused) { _, newValue in
                localFocus = newValue
            }
    }
}
