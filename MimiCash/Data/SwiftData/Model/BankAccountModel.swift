import Foundation
import SwiftData

@Model
final class BankAccountModel {
    var id: Int
    var name: String
    var balance: Decimal
    var currency: String
    
    init(from account: BankAccount) {
        self.id = account.id
        self.name = account.name
        self.balance = account.balance
        self.currency = account.currency
    }
    
    func toBankAccount() -> BankAccount {
        BankAccount(
            id: id,
            name: name,
            balance: balance,
            currency: currency
        )
    }
}
