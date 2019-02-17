@testable import Currencies
import XCTest

class CurrencyCellViewModelTests: XCTestCase {
    private var formatter: NumberFormatter!
    
    override func setUp() {
        super.setUp()
        formatter = NumberFormatter()
        formatter.decimalSeparator = "."
        formatter.minimumIntegerDigits = 1
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
    }
    
    func testFormatting() {
        let vm = CurrencyCellViewModel(Money(100.5, .eur), formatter)
        XCTAssertEqual(vm.countryFlagImageName, Resources.Images.countryFlagImageName(for: .eur))
        XCTAssertEqual(vm.currencyId, "EUR")
        XCTAssertEqual(vm.currencyName, Resources.Strings.currencyName(for: .eur))
        XCTAssertEqual(vm.amount, "100.50")
    }
    
    func testSetMoneyShouldUpdateAmount() {
        let vm = CurrencyCellViewModel(Money(100.5, .eur), formatter)
        vm.money = Money(200.2, .eur)
        XCTAssertEqual(vm.amount, "200.20")
    }
    
    func testSetMoneyShouldCallDelegate() {
        let delegate = Delegate()
        XCTAssertFalse(delegate.viewModelDidChangeCalled)
        let vm = CurrencyCellViewModel(Money(1, .eur), formatter)
        vm.delegate = delegate
        vm.money = Money(2, .eur)
        XCTAssertTrue(delegate.viewModelDidChangeCalled)
    }
    
    func testPostsNotificationOnAmountChangeAction() {
        var receivedMoney: Money? = nil
        
        let observer = NotificationCenter.default.addObserver(
            forName: CurrencyCellViewModel.moneyDidChangeNotification,
            object: nil, queue: nil) { notification in
                if let money = notification.userInfo?[CurrencyCellViewModel.moneyUserInfoKey] as? Money {
                    receivedMoney = money
                }
        }
        
        let vm = CurrencyCellViewModel(Money(1, .eur), formatter)
        vm.amountDidChange("2.5")
        XCTAssertEqual(receivedMoney, Money(2.5, .eur))
        
        NotificationCenter.default.removeObserver(observer)
    }
}

extension CurrencyCellViewModelTests {
    final class Delegate: CurrencyCellViewModelDelegate {
        var viewModelDidChangeCalled = false
        
        func viewModelDidChange(_ viewModel: CurrencyCellViewModel) {
            viewModelDidChangeCalled = true
        }
    }
}
