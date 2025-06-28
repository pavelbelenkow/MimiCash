import SwiftUI

struct BalanceSection: View {
    @Binding var viewModel: any BankAccountViewModel
    @FocusState.Binding var focusedField: BankAccountView.Field?
    
    let formattedBalance: String
    
    var body: some View {
        Section {
            HStack {
                Text(Spec.Text.balanceEmoji)
                    .frame(
                        width: Spec.Size.emojiSize,
                        height: Spec.Size.emojiSize
                    )
                
                Text(Spec.Text.balanceText)
                    .padding(.leading, Spec.Size.smallPadding)
                Spacer()
                
                if viewModel.state.isEditing {
                    TextField(
                        formattedBalance,
                        text: $viewModel.state.balanceInput
                    )
                    .foregroundStyle(.gray)
                    .multilineTextAlignment(.trailing)
                    .keyboardType(.decimalPad)
                    .focused($focusedField, equals: .balance)
                    .onChange(of: viewModel.state.balanceInput) { _, newValue in
                        viewModel.handleBalanceInput(newValue)
                    }
                } else {
                    Text(formattedBalance)
                        .spoiler(isOn: $viewModel.state.isSpoilerOn)
                }
            }
            .frame(height: Spec.Size.sectionHeight)
            .listRowInsets(Spec.Size.rowInsets)
            .listRowBackground(
                viewModel.state.isEditing ? Color.white : Color.accent
            )
        }
    }
}

// MARK: - Spec

private enum Spec {
    
    enum Text {
        static let balanceEmoji = "💰"
        static let balanceText = "Баланс"
    }
    
    enum Size {
        static let emojiSize: CGFloat = 22
        static let smallPadding: CGFloat = 8
        static let sectionHeight: CGFloat = 44
        static let rowInsets = EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)
    }
}
