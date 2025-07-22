struct BankAccountState {
    var balanceInput: String
    var lastValidBalanceInput: String
    var selectedCurrency: String
    var isEditing: Bool
    var isSpoilerOn: Bool
    var isPresentedDialog: Bool
    
    init(
        balanceInput: String = "",
        lastValidBalanceInput: String = "",
        selectedCurrency: String = "",
        isEditing: Bool = false,
        isSpoilerOn: Bool = false,
        isPresentedDialog: Bool = false
    ) {
        self.balanceInput = balanceInput
        self.lastValidBalanceInput = lastValidBalanceInput
        self.selectedCurrency = selectedCurrency
        self.isEditing = isEditing
        self.isSpoilerOn = isSpoilerOn
        self.isPresentedDialog = isPresentedDialog
    }
}
