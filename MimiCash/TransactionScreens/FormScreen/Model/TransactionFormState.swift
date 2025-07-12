import Foundation

// MARK: - TransactionFormState

struct TransactionFormState {
    // Core Data
    var selectedCategory: Category?
    var amount: String = ""
    var date: Date = Date()
    var time: Date = Date()
    var comment: String = ""
    
    // UI State
    var availableCategories: [Category] = []
    var categoriesLoadingState: ViewState<[Category]> = .idle
    var isCategoryPickerPresented: Bool = false
    var isDeleteAlertPresented: Bool = false
    var isValidationAlertPresented: Bool = false
    
    // Validation
    var validationErrors: Set<ValidationError> = []
    var isFormValid: Bool { validationErrors.isEmpty }
    
    // Loading States
    var isSaving: Bool = false
    var isDeleting: Bool = false
}

// MARK: - ValidationError

enum ValidationError: CaseIterable, Hashable {
    case categoryNotSelected
    case amountEmpty
    case amountInvalid
    case dateInFuture
    
    var message: String {
        switch self {
        case .categoryNotSelected: 
            return "Выберите категорию"
        case .amountEmpty:
            return "Введите сумму"
        case .amountInvalid: 
            return "Некорректная сумма"
        case .dateInFuture: 
            return "Дата не может быть в будущем"
        }
    }
}
