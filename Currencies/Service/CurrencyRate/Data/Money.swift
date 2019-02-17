import Foundation

struct Money: Equatable {
    let amount: Double
    let currency: Currency
    
    init(_ amount: Double, _ currency: Currency) {
        self.amount = amount
        self.currency = currency
    }
}
