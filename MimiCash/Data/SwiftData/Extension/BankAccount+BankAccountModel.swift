extension BankAccount {
    
    func toBankAccountModel() -> BankAccountModel {
        BankAccountModel(from: self)
    }
}
