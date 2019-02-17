@testable import Currencies
import XCTest

class DefaultCurrencyRateServiceTests: XCTestCase {
    private var apiClient: ApiClientMock!
    private var service: CurrencyRateService!
    
    override func setUp() {
        super.setUp()
        
        apiClient = ApiClientMock()
        service = DefaultCurrencyRateService(apiClient)
    }
    
    func testQueryCurrencyRatesSuccess() {
        apiClient.sendHandler = { request, completionHandler in
            guard request is CurrencyRatesRequest.Get else {
                return
            }
            guard let completionHandler = completionHandler as? Consumer<Result<CurrencyRatesDto>> else {
                return
            }
            let currencyRatesDto = CurrencyRatesDto(
                base: "EUR",
                rates: [
                    "GBP": 0.89615,
                    "RUB": 79.39,
                    
                    "usd": 1.1607,
                    "jpy": 129.25,
                    
                ]
            )
            completionHandler(.success(currencyRatesDto))
        }
        
        var isResponseReceived = false
        
        service.queryCurrencyRates(base: .eur) { result in
            isResponseReceived = true
            do {
                let currencyRates = try result.getValue()
                XCTAssertEqual(currencyRates.base, .eur)
                XCTAssertEqual(currencyRates.rates[.gbp], 0.89615)
                XCTAssertEqual(currencyRates.rates[.rub], 79.39)
                XCTAssertEqual(currencyRates.rates[.usd], 1.1607)
                XCTAssertEqual(currencyRates.rates[.jpy], 129.25)
                XCTAssertEqual(currencyRates.rates.count, 4)
            } catch {
                XCTFail("Error: \(error)")
            }
        }
        
        XCTAssertTrue(isResponseReceived)
    }
    
    func testQueryCurrencyRatesFailure() {
        let expectedError = TextError("Some Error")
        
        apiClient.sendHandler = { request, completionHandler in
            guard request is CurrencyRatesRequest.Get else {
                return
            }
            guard let completionHandler = completionHandler as? Consumer<Result<CurrencyRatesDto>> else {
                return
            }
            completionHandler(.failure(expectedError))
        }
        
        var isResponseReceived = false
        
        service.queryCurrencyRates(base: .eur) { result in
            isResponseReceived = true
            
            switch result {
            case .success(_):
                XCTFail("Error is expected")
            case .failure(let error):
                XCTAssertTrue(error is TextError)
                if let actualError = error as? TextError {
                    XCTAssertEqual(actualError, expectedError)
                }
            }
        }
        
        XCTAssertTrue(isResponseReceived)
    }
}
