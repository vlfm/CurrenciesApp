import Foundation

struct CurrencyRatesDto: Codable {
    let base: String
    let rates: [String: Double]
}
