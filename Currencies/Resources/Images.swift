import UIKit

extension Resources.Images {
    static func countryFlag(for currency: Currency) -> UIImage? {
        let name = countryFlagImageName(for: currency)
        return UIImage(named: name)
    }
}

extension Resources.Images {
    static func countryFlagImageName(for currency: Currency) -> String {
        return "Country.\(currency.rawValue)"
    }
}
