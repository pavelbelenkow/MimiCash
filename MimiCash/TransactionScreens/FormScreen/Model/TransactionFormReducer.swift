import Foundation

// MARK: - TransactionFormReducer

struct TransactionFormReducer {
    
    static func reduce(
        state: TransactionFormState, 
        action: TransactionFormAction
    ) -> TransactionFormState {
        var newState = state
        
        switch action {
        // Data Mutations
        case let .categorySelected(category):
            newState.selectedCategory = category
            newState.isCategoryPickerPresented = false
            
        case let .amountChanged(amount):
            newState.amount = validateAmountInput(amount)
            
        case let .dateChanged(date):
            newState.date = min(date, Date())
            
        case let .timeChanged(time):
            newState.time = time
            
        case let .commentChanged(comment):
            newState.comment = comment
            
        // UI State
        case let .categoryPickerToggled(isPresented):
            newState.isCategoryPickerPresented = isPresented
            
        case let .deleteAlertToggled(isPresented):
            newState.isDeleteAlertPresented = isPresented
            
        case let .validationAlertToggled(isPresented):
            newState.isValidationAlertPresented = isPresented
            
        // Categories Loading
        case .loadCategoriesRequested:
            newState.categoriesLoadingState = .loading
            
        case let .categoriesLoaded(categories):
            newState.availableCategories = categories
            newState.categoriesLoadingState = .success(categories)
            
        case let .categoriesLoadFailed(error):
            newState.categoriesLoadingState = .error(error)
            
        // Form Submission
        case .saveRequested:
            newState.isSaving = false
            
        case .saveStarted:
            newState.isSaving = true
            
        case .saveCompleted:
            newState.isSaving = false
            
        case let .saveFailed(error):
            newState.isSaving = false
            // TODO: Could add error state here
            
        // Deletion
        case .deleteRequested:
            newState.isDeleteAlertPresented = true
            
        case .deleteStarted:
            newState.isDeleting = true
            newState.isDeleteAlertPresented = false
            
        case .deleteCompleted:
            newState.isDeleting = false
            
        case let .deleteFailed(error):
            newState.isDeleting = false
            // TODO: Could add error state here
            
        // Validation
        case .validateForm:
            // Trigger validation
            break
            
        case let .validationCompleted(errors):
            newState.validationErrors = errors
            if !errors.isEmpty {
                newState.isValidationAlertPresented = true
            }
        }
        
        return newState
    }
    
    // MARK: - Private Methods
    
    private static func validateAmountInput(_ input: String) -> String {
        let decimalSeparator = Locale.current.decimalSeparator ?? "."
        let groupingSeparator = Locale.current.groupingSeparator ?? " "
        
        let allowedCharacters = CharacterSet.decimalDigits
            .union(CharacterSet(charactersIn: decimalSeparator))
            .union(CharacterSet(charactersIn: groupingSeparator))
        
        return input.filter { char in
            guard let scalar = char.unicodeScalars.first else { return false }
            return allowedCharacters.contains(scalar)
        }
    }
} 
