import Foundation

// MARK: - TransactionFormViewModel Protocol

protocol TransactionFormViewModel {
    var state: TransactionFormState { get }
    var mode: TransactionFormMode { get }
    var navigationTitle: String { get }
    var canSave: Bool { get }
    var canDelete: Bool { get }
    
    var onTransactionSaved: (() -> Void)? { get set }
    var onTransactionDeleted: (() -> Void)? { get set }
    var onDismissRequested: (() -> Void)? { get set }
    
    func dispatch(_ action: TransactionFormAction)
    func performDelete() async
    func loadInitialData() async
}

// MARK: - TransactionFormProvider Protocol

protocol TransactionFormProvider: TransactionsProvider, BankAccountsProvider, CategoriesProvider {}

// MARK: - TransactionFormViewModel Implementation

@Observable
final class TransactionFormViewModelImp: TransactionFormViewModel, TransactionFormProvider {
    
    // MARK: - TransactionFormProvider
    let transactionsService: TransactionsService
    let categoriesService: CategoriesService
    let bankAccountsService: BankAccountsService
    
    // MARK: - Redux State
    private(set) var state: TransactionFormState
    let mode: TransactionFormMode
    
    // MARK: - Callbacks
    var onTransactionSaved: (() -> Void)?
    var onTransactionDeleted: (() -> Void)?
    var onDismissRequested: (() -> Void)?
    
    // MARK: - Computed Properties
    var navigationTitle: String {
        mode.navigationTitle
    }
    
    var canSave: Bool {
        !state.isSaving && !state.isDeleting
    }
    
    var canDelete: Bool {
        if case .edit = mode {
            return !state.isDeleting && !state.isSaving
        }
        return false
    }
    
    // MARK: - Init
    init(
        mode: TransactionFormMode,
        transactionsService: TransactionsService,
        categoriesService: CategoriesService,
        bankAccountsService: BankAccountsService
    ) {
        self.mode = mode
        self.transactionsService = transactionsService
        self.categoriesService = categoriesService
        self.bankAccountsService = bankAccountsService
        self.state = TransactionFormState()
        
        setupInitialState()
    }
    
    // MARK: - Public Methods
    func dispatch(_ action: TransactionFormAction) {
        // Reduce state
        state = TransactionFormReducer.reduce(state: state, action: action)
        
        // Handle side effects
        handleSideEffects(for: action)
    }
    
    func loadInitialData() async {
        dispatch(.loadCategoriesRequested)
        
        do {
            let direction = mode.direction
            let categories = try await fetchCategories(for: direction)
            dispatch(.categoriesLoaded(categories))
            
            if case .edit(let transaction) = mode {
                
                if let matchingCategory = categories.first(where: { $0.id == transaction.category.id }) {
                    dispatch(.categorySelected(matchingCategory))
                } else {
                    var updatedCategories = categories
                    updatedCategories.append(transaction.category)
                    dispatch(.categoriesLoaded(updatedCategories))
                    dispatch(.categorySelected(transaction.category))
                }
            }
        } catch {
            dispatch(.categoriesLoadFailed(error.localizedDescription))
        }
    }
    
    // MARK: - Private Methods
    
    private func setupInitialState() {
        if case let .edit(transaction) = mode {
            state.amount = transaction.amount.stringValue
            state.date = transaction.transactionDate
            state.time = transaction.transactionDate
            state.comment = transaction.comment ?? ""
        }
    }
    
    private func handleSideEffects(for action: TransactionFormAction) {
        switch action {
        case .saveRequested:
            Task {
                await performValidationAndSave()
            }
            
        case .deleteRequested:
            dispatch(.deleteAlertToggled(true))
            
        case .validateForm:
            performValidation()
            
        case .saveCompleted:
            onTransactionSaved?()
            
        case .deleteCompleted:
            onTransactionDeleted?()
            
        default:
            break
        }
    }
    
    private func performValidation() {
        var errors: Set<ValidationError> = []
        
        if state.selectedCategory == nil {
            errors.insert(.categoryNotSelected)
        }
        
        if state.amount.isEmpty {
            errors.insert(.amountEmpty)
        } else {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.groupingSeparator = Locale.current.groupingSeparator
            formatter.decimalSeparator = Locale.current.decimalSeparator
            
            let cleanAmount = state.amount
                .replacingOccurrences(of: " ", with: "")
                .replacingOccurrences(of: Locale.current.groupingSeparator ?? " ", with: "")
            
            if let value = formatter.number(from: cleanAmount)?.doubleValue {
                if value <= 0 {
                    errors.insert(.amountInvalid)
                }
            } else {
                errors.insert(.amountInvalid)
            }
        }
        
        if state.date > Date() {
            errors.insert(.dateInFuture)
        }
        
        dispatch(.validationCompleted(errors))
    }
    
    private func performValidationAndSave() async {
        dispatch(.validateForm)
        
        if state.isFormValid {
            dispatch(.saveStarted)
            
            do {
                try await performSave()
                dispatch(.saveCompleted)
            } catch {
                dispatch(.saveFailed(error.localizedDescription))
            }
        }
    }
    
    private func performSave() async throws {
        do {
            let transaction = try await createTransaction()
            
            switch mode {
            case .create:
                _ = try await post(transaction: transaction)
            case .edit(let existingTransaction):
                let updatedTransaction = Transaction(
                    id: existingTransaction.id,
                    account: transaction.account,
                    category: transaction.category,
                    amount: transaction.amount,
                    transactionDate: transaction.transactionDate,
                    comment: transaction.comment
                )
                _ = try await update(transaction: updatedTransaction)
            }
            
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func performDelete() async {
        guard case .edit(let transaction) = mode else { return }
        
        dispatch(.deleteStarted)
        
        do {
            try await delete(transactionId: transaction.id)
            dispatch(.deleteCompleted)
        } catch {
            dispatch(.deleteFailed(error.localizedDescription))
        }
    }
    
    private func createTransaction() async throws -> Transaction {
        let dateTime = combineDateAndTime(date: state.date, time: state.time)
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = Locale.current.groupingSeparator
        formatter.decimalSeparator = Locale.current.decimalSeparator
        
        let cleanAmount = state.amount
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: Locale.current.groupingSeparator ?? " ", with: "")
        
        let amount: String
        if let value = formatter.number(from: cleanAmount)?.doubleValue {
            amount = String(format: "%.2f", value)
        } else {
            amount = "0.00"
        }
        
        let account = try await fetchCurrentAccount()
        
        return Transaction(
            id: 0, // Временный ID, будет заменен в TransactionsService
            account: account,
            category: state.selectedCategory ?? Category(id: 0, name: "", emoji: "💰", isIncome: mode.direction),
            amount: Decimal(string: amount) ?? 0,
            transactionDate: dateTime,
            comment: state.comment.isEmpty ? nil : state.comment
        )
    }
    
    private func combineDateAndTime(date: Date, time: Date) -> Date {
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
        let timeComponents = calendar.dateComponents([.hour, .minute], from: time)
        
        var combined = DateComponents()
        combined.year = dateComponents.year
        combined.month = dateComponents.month
        combined.day = dateComponents.day
        combined.hour = timeComponents.hour
        combined.minute = timeComponents.minute
        
        return calendar.date(from: combined) ?? date
    }
} 
