import Foundation

final class CurrencyRateServiceMock {
    typealias QueryCurrencyRatesHandler = (Currency?, Consumer<Result<CurrencyRates>>) -> Void
    var queryCurrencyRatesHandler: QueryCurrencyRatesHandler?
}

extension CurrencyRateServiceMock: CurrencyRateService {
    func queryCurrencyRates(base: Currency?,
                            _ completionHandler: @escaping Consumer<Result<CurrencyRates>>) {
        queryCurrencyRatesHandler?(base, completionHandler)
    }
}
