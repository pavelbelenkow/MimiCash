import Foundation

// MARK: - BankAccountViewModel Protocol

protocol BankAccountViewModel {
    var viewState: ViewState<BankAccount> { get }
    var state: BankAccountState { get set }
    
    func loadCurrentAccount() async
    func updateAccount() async
    func handleShake()
    func handleEditToggle()
    func handleCurrencyTap()
    func handleBalanceInput(_ value: String)
}

@Observable
final class BankAccountViewModelImp: BankAccountViewModel, BankAccountsProvider {
    
    // MARK: - BankAccountsProvider Properties
    let bankAccountsService: BankAccountsService
    
    // MARK: - Properties
    var viewState: ViewState<BankAccount>
    var state: BankAccountState
    
    // MARK: - Init
    init(
        bankAccountsService: BankAccountsService = ServiceFactory.shared.createBankAccountsService(),
        viewState: ViewState<BankAccount> = .idle,
        state: BankAccountState = BankAccountState()
    ) {
        self.bankAccountsService = bankAccountsService
        self.viewState = viewState
        self.state = state
    }
    
    // MARK: - Methods
    func loadCurrentAccount() async {
        viewState = .loading
        
        do {
            let account = try await fetchCurrentAccount()
            viewState = .success(account)
            
            state.balanceInput = account.balance.stringValue
            state.lastValidBalanceInput = state.balanceInput
            state.selectedCurrency = account.currency
        } catch {
            viewState = .error(error.localizedDescription)
        }
    }
    
    func updateAccount() async {
        guard
            case let .success(oldAccount) = viewState,
            let balance = Decimal(string: state.balanceInput.replacingOccurrences(of: ",", with: ".")),
            balance != oldAccount.balance || state.selectedCurrency != oldAccount.currency
        else { return }
        
        viewState = .loading
        
        let updatedAccount = BankAccount(
            id: oldAccount.id,
            name: oldAccount.name,
            balance: balance,
            currency: state.selectedCurrency
        )
        
        do {
            let result = try await update(account: updatedAccount)
            viewState = .success(result)
            state.isEditing = false
        } catch {
            viewState = .error(error.localizedDescription)
        }
    }
    
    func handleShake() {
        state.isSpoilerOn.toggle()
    }
    
    func handleEditToggle() {
        if state.isEditing {
            Task { await updateAccount() }
        }
        
        state.isEditing.toggle()
    }
    
    func handleCurrencyTap() {
        if state.isEditing {
            state.isPresentedDialog = true
        }
    }
    
    func handleBalanceInput(_ value: String) {
        if isValidBalanceInput(value) {
            state.lastValidBalanceInput = value
            
            if let commaIndex = value.firstIndex(of: ",") {
                var fixed = value
                fixed.replaceSubrange(commaIndex...commaIndex, with: ".")
                state.balanceInput = fixed
                state.lastValidBalanceInput = fixed
            } else {
                state.balanceInput = value
            }
        } else {
            state.balanceInput = state.lastValidBalanceInput
        }
    }
}

// MARK: - Private Methods

private extension BankAccountViewModelImp {
    
    func isValidBalanceInput(_ text: String) -> Bool {
        let allowed = CharacterSet(charactersIn: "0123456789.,")
        if text.isEmpty { return true }
        if text.rangeOfCharacter(from: allowed.inverted) != nil {
            return false
        }
        let dots = text.filter { $0 == "." || $0 == "," }
        return dots.count <= 1
    }
}
