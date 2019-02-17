import Foundation

extension Resources.Strings {
    static func currencyName(for currency: Currency) -> String {
        let key = currencyNameKey(for: currency)
        return NSLocalizedString(key, comment: "")
    }
}

extension Resources.Strings {
    static func currencyNameKey(for currency: Currency) -> String {
        return "Currency.\(currency.rawValue)"
    }
}
