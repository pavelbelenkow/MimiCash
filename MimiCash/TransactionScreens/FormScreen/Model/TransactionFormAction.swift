import Foundation

// MARK: - TransactionFormAction

enum TransactionFormAction {
    // Data Actions
    case categorySelected(Category?)
    case amountChanged(String)
    case dateChanged(Date)
    case timeChanged(Date)
    case commentChanged(String)
    
    // UI Actions
    case categoryPickerToggled(Bool)
    case deleteAlertToggled(Bool)
    case validationAlertToggled(Bool)
    
    // Async Actions
    case loadCategoriesRequested
    case categoriesLoaded([Category])
    case categoriesLoadFailed(String)
    
    // Form Actions
    case saveRequested
    case saveStarted
    case saveCompleted
    case saveFailed(String)
    
    case deleteRequested
    case deleteStarted
    case deleteCompleted
    case deleteFailed(String)
    
    // Validation Actions
    case validateForm
    case validationCompleted(Set<ValidationError>)
}
