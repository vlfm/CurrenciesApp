import Foundation

protocol CurrencyRateService {
    func queryCurrencyRates(base: Currency?,
                            _ completionHandler: @escaping Consumer<Result<CurrencyRates>>)
}
