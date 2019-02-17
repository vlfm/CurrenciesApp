@testable import Currencies
import XCTest

class DefaultApiClientTests: XCTestCase {
    private let baseUrl = URL(string: "http://example.com")!
    private var network: NetworkMock!
    private var apiClient: ApiClient!
    
    override func setUp() {
        super.setUp()
        
        network = NetworkMock()
        apiClient = DefaultApiClient(network, baseUrl: baseUrl)
    }
    
    func testCurrencyRatesRequestGetSuccess() {
        let jsonResponse =
        """
        {"base":"EUR","date":"2018-09-06","rates":{"AUD":1.6126,"BGN":1.9513,"BRL":4.7807,"CAD":1.5302,"CHF":1.1249,"CNY":7.9266,"CZK":25.655,"DKK":7.4394,"GBP":0.89615,"HKD":9.1112,"HRK":7.4168,"HUF":325.73,"IDR":17283.0,"ILS":4.1609,"INR":83.523,"ISK":127.5,"JPY":129.25,"KRW":1301.7,"MXN":22.313,"MYR":4.8008,"NOK":9.7533,"NZD":1.7592,"PHP":62.446,"PLN":4.3083,"RON":4.6277,"RUB":79.39,"SEK":10.566,"SGD":1.5963,"THB":38.041,"TRY":7.6105,"USD":1.1607,"ZAR":17.782}
        }
        """
        
        let dataResponse = jsonResponse.data(using: .utf8)
        let expectedRequestUrl = baseUrl.appendingPathComponent("latest?base=EUR")
        
        network.sendHandler = { request, completionHandler in
            XCTAssertEqual(request.url, expectedRequestUrl)
            let response = DataNetworkResponse(value: dataResponse,
                                               response: HTTPURLResponse(), error: nil)
            completionHandler(response)
        }
        
        var isResponseReceived = false
        
        let request = CurrencyRatesRequest.Get(base: "EUR")
        apiClient.send(request) { result in
            isResponseReceived = true
            
            do {
                let currencyRates = try result.getValue()
                XCTAssertEqual(currencyRates.base, "EUR")
                XCTAssertEqual(currencyRates.rates["JPY"], 129.25)
                XCTAssertEqual(currencyRates.rates["RUB"], 79.39)
                XCTAssertEqual(currencyRates.rates["USD"], 1.1607)
            } catch {
                XCTFail("Error: \(error)")
            }
        }
        
        XCTAssertTrue(isResponseReceived)
    }
    
    func testCurrencyRatesRequestGetFailure() {
        let expectedError = TextError("Some Error")
        
        network.sendHandler = { request, completionHandler in
            let response = DataNetworkResponse(value: nil,
                                               response: HTTPURLResponse(), error: expectedError)
            completionHandler(response)
        }
        
        var isResponseReceived = false
        
        let request = CurrencyRatesRequest.Get(base: "EUR")
        apiClient.send(request) { result in
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
