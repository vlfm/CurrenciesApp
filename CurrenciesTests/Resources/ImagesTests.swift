@testable import Currencies
import XCTest

class ImagesTests: XCTestCase {
    func testCurrencyCountryFlagImages() {
        for currency in Currency.allCases {
            XCTAssertNotNil(Resources.Images.countryFlag(for: currency),
                            "Missing country flag image for \(currency.rawValue)")
        }
    }
}
