import Foundation

struct CurrencyRates {
    let base: Currency
    let rates: [Currency: Double]
}

extension CurrencyRates {
    private var allRates: [Currency: Double] {
        var rates = self.rates
        rates[base] = 1
        return rates
    }
}

extension CurrencyRates {
    func convert(_ money: Money, to currency: Currency) -> Money? {
        guard let sourceRate = allRates[money.currency] else {
            return nil
        }
        guard let destinationRate = allRates[currency] else {
            return nil
        }
        
        let rate = destinationRate / sourceRate
        
        let amount = money.amount * rate
        return Money(amount, currency)
    }
}

extension CurrencyRates {
    init(dto: CurrencyRatesDto) throws {
        guard let base = Currency(rawValue: dto.base.lowercased()) else {
            throw TextError("Unknown base currency \(dto.base)")
        }
        
        var rates: [Currency: Double] = [:]
        
        for key in dto.rates.keys {
            if let currency = Currency(rawValue: key.lowercased()) {
                rates[currency] = dto.rates[key]
            }
        }
        
        self.base = base
        self.rates = rates
    }
}
