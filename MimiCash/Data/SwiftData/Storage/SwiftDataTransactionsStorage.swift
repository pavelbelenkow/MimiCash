import Foundation
import SwiftData

actor SwiftDataTransactionsStorage: TransactionsStorage {
    
    // MARK: - Private Properties
    private let modelContext: ModelContext
    
    // MARK: - Init
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    // MARK: - TransactionsStorage Implementation
    var transactions: [Transaction] {
        get async {
            let descriptor = FetchDescriptor<TransactionModel>()
            
            do {
                let models = try modelContext.fetch(descriptor)
                return models.map { $0.toTransaction() }
            } catch {
                print("Error fetching operations: \(error)")
                return []
            }
        }
    }
    
    func create(_ transaction: Transaction) async {
        let model = TransactionModel(from: transaction)
        modelContext.insert(model)
        
        do {
            try modelContext.save()
        } catch {
            print("Error creating operation: \(error)")
        }
    }
    
    func update(_ transaction: Transaction) async {
        let transactionId = transaction.id
        let descriptor = FetchDescriptor<TransactionModel>(
            predicate: #Predicate<TransactionModel> { $0.id == transactionId }
        )
        
        do {
            let models = try modelContext.fetch(descriptor)
            
            if let model = models.first {
                model.accountId = transaction.account.id
                model.accountName = transaction.account.name
                model.accountBalance = transaction.account.balance
                model.accountCurrency = transaction.account.currency
                model.categoryId = transaction.category.id
                model.categoryName = transaction.category.name
                model.categoryEmoji = String(transaction.category.emoji)
                model.categoryIsIncome = transaction.category.isIncome == .income
                model.amount = transaction.amount
                model.transactionDate = transaction.transactionDate
                model.comment = transaction.comment
                
                try modelContext.save()
            }
        } catch {
            print("Error updating operation: \(error)")
        }
    }
    
    func delete(id: Int) async {
        let descriptor = FetchDescriptor<TransactionModel>(
            predicate: #Predicate<TransactionModel> { $0.id == id }
        )
        
        do {
            let models = try modelContext.fetch(descriptor)
            
            for model in models {
                modelContext.delete(model)
            }
            
            try modelContext.save()
        } catch {
            print("Error deleting operation with id \(id): \(error)")
        }
    }
    
    func getTransactions(from startDate: Date, to endDate: Date) async -> [Transaction] {
        let descriptor = FetchDescriptor<TransactionModel>(
            predicate: #Predicate<TransactionModel> {
                $0.transactionDate >= startDate && $0.transactionDate <= endDate
            }
        )
        
        do {
            let models = try modelContext.fetch(descriptor)
            return models.map { $0.toTransaction() }
        } catch {
            print("Error fetching operations for date range: \(error)")
            return []
        }
    }
    
    func clear() async {
        let descriptor = FetchDescriptor<TransactionModel>()
        
        do {
            let models = try modelContext.fetch(descriptor)
            
            for model in models {
                modelContext.delete(model)
            }
            
            try modelContext.save()
        } catch {
            print("Error clearing operations: \(error)")
        }
    }
} 
