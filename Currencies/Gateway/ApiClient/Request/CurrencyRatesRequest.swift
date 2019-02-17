import Foundation

struct CurrencyRatesRequest {
}

extension CurrencyRatesRequest {
    struct Get: ApiRequest {
        typealias Response = CurrencyRatesDto
        
        let base: String?
        
        let method = "GET"
        let path = "latest"
        
        var query: String? {
            if let base = base {
                return "base=\(base)"
            }
            return nil
        }
    }
}
