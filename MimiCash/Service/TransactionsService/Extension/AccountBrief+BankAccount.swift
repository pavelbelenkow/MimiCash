import Foundation

extension AccountBrief {
    
    func toBankAccount() -> BankAccount {
        BankAccount(
            id: id,
            name: name,
            balance: Decimal(string: balance) ?? 0,
            currency: currency
        )
    }
}
