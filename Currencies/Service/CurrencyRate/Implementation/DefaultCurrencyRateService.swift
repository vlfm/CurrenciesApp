import Foundation

final class DefaultCurrencyRateService {
    private let apiClient: ApiClient
    
    init(_ apiClient: ApiClient) {
        self.apiClient = apiClient
    }
}

extension DefaultCurrencyRateService: CurrencyRateService {
    func queryCurrencyRates(base: Currency?,
                            _ completionHandler: @escaping Consumer<Result<CurrencyRates>>) {
        let request = CurrencyRatesRequest.Get(base: base?.rawValue)
        apiClient.send(request) { result in
            do {
                let dto = try result.getValue()
                let currencyRateList = try CurrencyRates(dto: dto)
                completionHandler(.success(currencyRateList))
            } catch {
                completionHandler(.failure(error))
            }
        }
    }
}
