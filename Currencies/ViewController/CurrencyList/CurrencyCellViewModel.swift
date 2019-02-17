import Foundation

protocol CurrencyCellViewModelDelegate: AnyObject {
    func viewModelDidChange(_ viewModel: CurrencyCellViewModel)
}

final class CurrencyCellViewModel {
    weak var delegate: CurrencyCellViewModelDelegate?
    
    var money: Money {
        didSet {
            amount = amountFormatter.string(from: NSNumber(value: money.amount)) ?? ""
            delegate?.viewModelDidChange(self)
        }
    }
    
    var countryFlagImageName: String
    var currencyId: String
    var currencyName: String
    var amount: String
    
    private let amountFormatter: NumberFormatter
    private let notificationCenter: NotificationCenter
    
    init(_ money: Money,
         _ amountFormatter: NumberFormatter,
         _ notificationCenter: NotificationCenter = .default) {
        self.money = money
        self.amountFormatter = amountFormatter
        self.notificationCenter = notificationCenter
        
        countryFlagImageName = Resources.Images.countryFlagImageName(for: money.currency)
        currencyId = money.currency.rawValue.uppercased()
        currencyName = Resources.Strings.currencyName(for: money.currency)
        amount = amountFormatter.string(from: NSNumber(value: money.amount)) ?? ""
    }
}

extension CurrencyCellViewModel {
    static let moneyDidChangeNotification = Notification.Name("CurrencyCellViewModel.MoneyDidChange")
    static let moneyUserInfoKey = "CurrencyCellViewModel.MoneyDidChange.Money"
}

extension CurrencyCellViewModel {
    func amountDidChange(_ amountString: String?) {
        let preparedAmountString = self.preparedAmountString(amountString)
        let amount = amountFormatter.number(from: preparedAmountString)?.doubleValue ?? 0
        money = Money(amount, money.currency)
        notificationCenter.post(name: CurrencyCellViewModel.moneyDidChangeNotification,
                                object: self,
                                userInfo: [CurrencyCellViewModel.moneyUserInfoKey: money])
    }
}

extension CurrencyCellViewModel {
    private func preparedAmountString(_ string: String?) -> String {
        guard let string = string else {
            return "0"
        }
        
        if string.isEmpty {
            return "0"
        }
        if let decimalSeparator = amountFormatter.decimalSeparator {
            return string.replacingOccurrences(of: ".", with: decimalSeparator)
        }
        return string
    }
}
