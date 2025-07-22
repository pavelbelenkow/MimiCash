import Foundation

extension AccountResponse {
    
    func toBankAccount() -> BankAccount {
        BankAccount(
            id: id,
            name: name,
            balance: Decimal(string: balance) ?? 0,
            currency: currency
        )
    }
}
