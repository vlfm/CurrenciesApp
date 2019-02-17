import Foundation

final class AppContext {
    let apiClient: ApiClient
    let currencyRateService: CurrencyRateService
    
    init() {
        let baseUrl = URL(string: "https://revolut.duckdns.org")!
        apiClient = DefaultApiClient(URLSession.shared,
                                     baseUrl: baseUrl)
        currencyRateService = DefaultCurrencyRateService(apiClient)
    }
}
