import Foundation
import SwiftData

actor SwiftDataBankAccountsStorage: BankAccountsStorage {
    
    // MARK: - Private Properties
    private let modelContext: ModelContext
    
    // MARK: - Init
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    // MARK: - BankAccountsStorage Implementation
    var accounts: [BankAccount] {
        get async {
            let descriptor = FetchDescriptor<BankAccountModel>()
            
            do {
                let models = try modelContext.fetch(descriptor)
                return models.map { $0.toBankAccount() }
            } catch {
                print("Error fetching bank accounts: \(error)")
                return []
            }
        }
    }
    
    func get(id: Int) async -> BankAccount? {
        let descriptor = FetchDescriptor<BankAccountModel>(
            predicate: #Predicate<BankAccountModel> { $0.id == id }
        )
        
        do {
            let models = try modelContext.fetch(descriptor)
            return models.first?.toBankAccount()
        } catch {
            print("Error fetching bank account with id \(id): \(error)")
            return nil
        }
    }
    
    func create(_ account: BankAccount) async {
        let model = BankAccountModel(from: account)
        modelContext.insert(model)
        
        do {
            try modelContext.save()
        } catch {
            print("Error creating bank account: \(error)")
        }
    }
    
    func update(_ account: BankAccount) async {
        let accountId = account.id
        let descriptor = FetchDescriptor<BankAccountModel>(
            predicate: #Predicate<BankAccountModel> { $0.id == accountId }
        )
        
        do {
            let models = try modelContext.fetch(descriptor)
            if let model = models.first {
                model.name = account.name
                model.balance = account.balance
                model.currency = account.currency
                
                try modelContext.save()
            }
        } catch {
            print("Error updating bank account: \(error)")
        }
    }
    
    func delete(id: Int) async {
        let descriptor = FetchDescriptor<BankAccountModel>()
        
        do {
            let models = try modelContext.fetch(descriptor)
            
            for model in models {
                if model.id == id {
                    modelContext.delete(model)
                }
            }
            
            try modelContext.save()
        } catch {
            print("Error deleting bank account with id \(id): \(error)")
        }
    }
    
    func getCurrentAccount() async -> BankAccount? {
        let descriptor = FetchDescriptor<BankAccountModel>()
        
        do {
            let models = try modelContext.fetch(descriptor)
            return models.first?.toBankAccount()
        } catch {
            print("Error fetching current account: \(error)")
            return nil
        }
    }
    
    func clear() async {
        let descriptor = FetchDescriptor<BankAccountModel>()
        
        do {
            let models = try modelContext.fetch(descriptor)
            
            for model in models {
                modelContext.delete(model)
            }
            
            try modelContext.save()
        } catch {
            print("Error clearing bank accounts: \(error)")
        }
    }
} 
