extension BankAccount {
    
    func toAccountUpdateBody() -> AccountUpdateBody {
        AccountUpdateBody(
            name: name,
            balance: String(describing: balance),
            currency: currency
        )
    }
}
