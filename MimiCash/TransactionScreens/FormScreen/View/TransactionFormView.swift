import SwiftUI

struct TransactionFormView: View {
    @State private var viewModel: TransactionFormViewModel
    @FocusState private var focusedField: Field?
    let onDismiss: () -> Void
    let onTransactionChanged: (() -> Void)?
    
    enum Field: Hashable {
        case amount, comment
    }
    
    init(
        viewModel: TransactionFormViewModel,
        onDismiss: @escaping () -> Void,
        onTransactionChanged: (() -> Void)? = nil
    ) {
        self.viewModel = viewModel
        self.onDismiss = onDismiss
        self.onTransactionChanged = onTransactionChanged
    }
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    CategoryRow(
                        selectedCategory: viewModel.state.selectedCategory,
                        availableCategories: viewModel.state.availableCategories,
                        onCategorySelected: { 
                            viewModel.dispatch(.categorySelected($0))
                            focusedField = nil
                        }
                    )
                    AmountRow(
                        amount: amountBinding,
                        onAmountChange: { viewModel.dispatch(.amountChanged($0)) },
                        isFocused: focusedField == .amount
                    )
                    .focused($focusedField, equals: .amount)
                    .toolbar {
                        ToolbarItemGroup(placement: .keyboard) {
                            Spacer()
                            Button("Готово") { focusedField = nil }
                        }
                    }
                    DateRow(
                        date: dateBinding,
                        onDateChange: { 
                            viewModel.dispatch(.dateChanged($0))
                            focusedField = nil
                        }
                    )
                    TimeRow(
                        time: timeBinding,
                        date: viewModel.state.date,
                        onTimeChange: { 
                            viewModel.dispatch(.timeChanged($0))
                            focusedField = nil
                        }
                    )
                    CommentRow(
                        comment: commentBinding,
                        onCommentChange: { viewModel.dispatch(.commentChanged($0)) },
                        isFocused: focusedField == .comment
                    )
                    .focused($focusedField, equals: .comment)
                }
                
                if viewModel.canDelete {
                    Section("") {
                        ZStack {
                            Color.clear
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    viewModel.dispatch(.deleteRequested)
                                    focusedField = nil
                                }
                            
                            HStack {
                                Text(viewModel.mode.deleteButtonTitle)
                                    .foregroundStyle(.red)
                                
                                Spacer()
                            }
                        }
                    }
                }
            }
            .safeAreaPadding(.top)
            .navigationTitle(viewModel.navigationTitle)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отменить") {
                        focusedField = nil
                        onDismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(viewModel.mode.saveButtonTitle) {
                        focusedField = nil
                        viewModel.dispatch(.saveRequested)
                    }
                    .disabled(!viewModel.canSave)
                }
            }
            .disabled(viewModel.state.isSaving || viewModel.state.isDeleting)
            .onTapGesture {
                focusedField = nil
            }
        }
        .task {
            await viewModel.loadInitialData()
        }
        .onAppear {
            setupCallbacks()
        }
        .confirmationDialog(
            "Удалить операцию?",
            isPresented: .constant(viewModel.state.isDeleteAlertPresented),
            titleVisibility: .visible
        ) {
            Button("Удалить", role: .destructive) {
                Task {
                    focusedField = nil
                    await viewModel.performDelete()
                }
            }
            Button("Отменить", role: .cancel) {
                viewModel.dispatch(.deleteAlertToggled(false))
            }
        } message: {
            Text("Это действие нельзя отменить. Вы уверены, что хотите удалить эту операцию?")
        }
        .alert("Заполните все поля", isPresented: .constant(viewModel.state.isValidationAlertPresented)) {
            Button("OK") {
                viewModel.dispatch(.validationAlertToggled(false))
            }
        } message: {
            Text(viewModel.state.validationErrors.map(\.message).joined(separator: "\n"))
        }
        .overlay {
            if viewModel.state.isSaving || viewModel.state.isDeleting {
                ZStack {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                    ProgressView(viewModel.state.isSaving ? "Сохранение..." : "Удаление...")
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(8)
                }
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func setupCallbacks() {
        viewModel.onTransactionSaved = {
            onTransactionChanged?()
            onDismiss()
        }
        viewModel.onTransactionDeleted = {
            onTransactionChanged?()
            onDismiss()
        }
    }
    
    private var amountBinding: Binding<String> {
        Binding(
            get: { viewModel.state.amount },
            set: { viewModel.dispatch(.amountChanged($0)) }
        )
    }
    
    private var dateBinding: Binding<Date> {
        Binding(
            get: { viewModel.state.date },
            set: { viewModel.dispatch(.dateChanged($0)) }
        )
    }
    
    private var timeBinding: Binding<Date> {
        Binding(
            get: { viewModel.state.time },
            set: { viewModel.dispatch(.timeChanged($0)) }
        )
    }
    
    private var commentBinding: Binding<String> {
        Binding(
            get: { viewModel.state.comment },
            set: { viewModel.dispatch(.commentChanged($0)) }
        )
    }
}
