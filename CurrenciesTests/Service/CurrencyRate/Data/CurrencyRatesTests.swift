@testable import Currencies
import XCTest

class CurrencyRatesTests: XCTestCase {
    func testConvertMoney() {
        let currencyRates = CurrencyRates(
            base: .eur,
            rates:
            [
                .gbp: 0.89615,
                .rub: 79.39,
                .usd: 1.1607
            ]
        )
        
        let testData: [(Money, Currency, Money)] = [
            (Money(1, .eur), .eur, Money(1, .eur)),
            (Money(1, .eur), .gbp, Money(0.89615, .gbp)),
            (Money(1, .eur), .rub, Money(79.39, .rub)),
            (Money(1, .eur), .usd, Money(1.1607, .usd)),
            
            (Money(100, .eur), .gbp, Money(89.615, .gbp)),
            (Money(100, .eur), .rub, Money(7939, .rub)),
            (Money(100, .eur), .usd, Money(116.07, .usd)),
            
            (Money(0.89615, .gbp), .eur, Money(1, .eur)),
            (Money(79.39, .rub), .eur, Money(1, .eur)),
            (Money(1.1607, .usd), .eur, Money(1, .eur))
        ]
        
        for (money, currency, expected) in testData {
            if let actual = currencyRates.convert(money, to: currency) {
                XCTAssertEqual(actual.amount, expected.amount, accuracy: 0.0000000001)
                XCTAssertEqual(actual.currency, expected.currency)
            } else {
                XCTFail("Fail to convert \(money) to \(currency)")
            }
        }
    }
    
    func testConvertUnexpectedCurrencies() {
        let currencyRates = CurrencyRates(
            base: .eur,
            rates: [.rub: 79.39]
        )
        
        XCTAssertNil(currencyRates.convert(Money(1, .jpy), to: .eur))
        XCTAssertNil(currencyRates.convert(Money(1, .eur), to: .jpy))
    }
}
