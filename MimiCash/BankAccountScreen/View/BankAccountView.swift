import SwiftUI

struct BankAccountView: View {
    
    // MARK: - Field
    enum Field: Hashable {
        case balance
    }
    
    @State private var viewModel: any BankAccountViewModel
    @FocusState private var focusedField: Field?
    
    // MARK: - Init
    init(viewModel: any BankAccountViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        NavigationStack {
            EntityView(
                state: viewModel.viewState,
                title: Spec.Text.myAccountText,
                content: { account in
                    List {
                        BalanceSection(
                            viewModel: $viewModel,
                            focusedField: $focusedField,
                            formattedBalance: account.formattedBalance()
                        )
                        
                        CurrencySection(viewModel: $viewModel)
                    }
                    .listSectionSpacing(Spec.Spacing.sectionSpacing)
                    .safeAreaPadding(.top)
                    .refreshable {
                        Task {
                            await viewModel.loadCurrentAccount()
                        }
                    }
                }
            )
            .toolbar { toolbarContent }
        }
        .tint(.navBar)
        .scrollDismissesKeyboard(.immediately)
        .task {
            await viewModel.loadCurrentAccount()
        }
        .background {
            ShakeDetector {
                viewModel.handleShake()
            }
            .allowsHitTesting(false)
        }
    }
}

// MARK: - Subviews

private extension BankAccountView {
    
    @ToolbarContentBuilder
    var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                focusedField = .balance
                viewModel.handleEditToggle()
            } label: {
                Text(
                    viewModel.state.isEditing ? Spec.Text.saveButtonText : Spec.Text.editButtonText
                )
            }
        }
    }
}

// MARK: - Spec

private enum Spec {
    
    enum Text {
        static let myAccountText = "Мой счет"
        static let saveButtonText = "Сохранить"
        static let editButtonText = "Редактировать"
    }
    
    enum Spacing {
        static let sectionSpacing: CGFloat = 16
    }
}

#Preview {
    @Previewable @Environment(\.diContainer) var diContainer
    BankAccountView(
        viewModel: BankAccountViewModelImp(
            bankAccountsService: diContainer.bankAccountsService
        )
    )
}
