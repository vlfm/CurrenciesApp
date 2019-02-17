@testable import Currencies
import XCTest

class StringsTests: XCTestCase {
    func testCurrencyNames() {
        for currency in Currency.allCases {
            let key = Resources.Strings.currencyNameKey(for: currency)
            XCTAssertNotEqual(Resources.Strings.currencyName(for: currency), key,
                              "Missing currency name for \(currency.rawValue)")
        }
    }
}
