import SwiftUI

struct CurrencySection: View {
    @Binding var viewModel: any BankAccountViewModel
    
    var body: some View {
        Section {
            HStack {
                Text(Spec.Text.currencyText)
                Spacer()
                Text(viewModel.state.selectedCurrency.currencySymbol)
                    .foregroundStyle(viewModel.state.isEditing ? .gray : .black)
                
                if viewModel.state.isEditing {
                    Image(systemName: Spec.Text.chevronIcon)
                        .font(Spec.Text.chevronFont)
                        .foregroundStyle(.gray)
                }
            }
            .contentShape(Rectangle())
            .frame(height: Spec.Size.sectionHeight)
            .listRowInsets(Spec.Size.rowInsets)
            .listRowBackground(viewModel.state.isEditing ? Color.white : Color.circle)
            .confirmationDialog(
                Spec.Text.currencyText,
                isPresented: $viewModel.state.isPresentedDialog,
                titleVisibility: .visible,
                actions: { currencyOptions() }
            )
            .onTapGesture {
                viewModel.handleCurrencyTap()
            }
        }
    }
}

// MARK: - Subviews

private extension CurrencySection {
    
    @ViewBuilder
    func currencyOptions() -> some View {
        ForEach(CurrencyOption.allCases) { option in
            Button("\(option.title) \(option.symbol)") {
                guard option.id != viewModel.state.selectedCurrency else { return }
                viewModel.state.selectedCurrency = option.id
            }
            .tint(.navBar)
        }
    }
}


// MARK: - Spec

private enum Spec {
    
    enum Text {
        static let currencyText = "Валюта"
        static let chevronIcon = "chevron.right"
        static let chevronFont = Font.system(size: 13, weight: .bold)
    }
    
    enum Size {
        static let smallPadding: CGFloat = 8
        static let sectionHeight: CGFloat = 44
        static let rowInsets = EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)
    }
}
