@testable import Currencies
import XCTest

class CurrencyListViewModelTests: XCTestCase {
    private var currencyRateService: CurrencyRateServiceMock!
    private var viewModel: CurrencyListViewModel!
    
    override func setUp() {
        super.setUp()
        
        let formatter = NumberFormatter()
        formatter.decimalSeparator = "."
        formatter.minimumIntegerDigits = 1
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        
        currencyRateService = CurrencyRateServiceMock()
        viewModel = CurrencyListViewModel(currencyRateService, formatter, DirectExecutor())
    }
    
    func testTitle() {
        XCTAssertEqual(viewModel.title, NSLocalizedString("CurrencyList.Title", comment: ""))
    }
    
    func testRequestsCurrencyRatePeriodically() {
        var times = 3
        
        currencyRateService.queryCurrencyRatesHandler = { base, completionHandler in
            if times > 0 {
                times -= 1
                let currencyRates = CurrencyRates(base: base ?? .eur, rates: [:])
                completionHandler(.success(currencyRates))
            }
        }
        
        viewModel.resume()
        XCTAssertEqual(times, 0)
    }
    
    func testNotifiesDelegateAfterRequestCompletes() {
        var oneResponce = false
        currencyRateService.queryCurrencyRatesHandler = { base, completionHandler in
            if !oneResponce {
                oneResponce = true
                let currencyRates = CurrencyRates(base: base ?? .eur, rates: [:])
                completionHandler(.success(currencyRates))
            }
        }
        
        let delegate = Delegate()
        viewModel.delegate = delegate
        XCTAssertFalse(delegate.viewModelDidChangeCalled)
        viewModel.resume()
        XCTAssertTrue(delegate.viewModelDidChangeCalled)
    }
    
    func testCellViewModels() {
        setUpCurrencyRatesResponse()
        viewModel.resume()
        
        XCTAssertEqual(viewModel.baseMoney, Money(100, .eur))
        XCTAssertEqual(viewModel.currencyCellViewModels[0].money, Money(100, .eur))
        XCTAssertEqual(viewModel.currencyCellViewModels[1].money, Money(12925, .jpy))
        XCTAssertEqual(viewModel.currencyCellViewModels[2].money, Money(7939, .rub))
        XCTAssertEqual(viewModel.currencyCellViewModels[3].money, Money(120, .usd))
    }
    
    func testPromoteToBaseCurrency() {
        setUpCurrencyRatesResponse()
        viewModel.resume()
        
        viewModel.promoteToBaseCurrency(index: 2)
        XCTAssertEqual(viewModel.baseMoney, Money(7939, .rub))
        XCTAssertEqual(viewModel.currencyCellViewModels[0].money, Money(7939, .rub))
        XCTAssertEqual(viewModel.currencyCellViewModels[1].money, Money(100, .eur))
        XCTAssertEqual(viewModel.currencyCellViewModels[2].money, Money(12925, .jpy))
        XCTAssertEqual(viewModel.currencyCellViewModels[3].money, Money(120, .usd))
    }
    
    func testSetBaseMoney() {
        setUpCurrencyRatesResponse()
        viewModel.resume()
        
        viewModel.baseMoney = Money(1, .eur)
        XCTAssertEqual(viewModel.currencyCellViewModels[0].money, Money(1, .eur))
        XCTAssertEqual(viewModel.currencyCellViewModels[1].money, Money(129.25, .jpy))
        XCTAssertEqual(viewModel.currencyCellViewModels[2].money, Money(79.39, .rub))
        XCTAssertEqual(viewModel.currencyCellViewModels[3].money, Money(1.2, .usd))
    }
    
    private func setUpCurrencyRatesResponse() {
        var oneResponce = false
        currencyRateService.queryCurrencyRatesHandler = { base, completionHandler in
            if !oneResponce {
                oneResponce = true
                let currencyRates = CurrencyRates(base: base ?? .eur, rates:
                    [
                        .jpy: 129.25,
                        .rub: 79.39,
                        .usd: 1.2
                    ]
                )
                completionHandler(.success(currencyRates))
            }
        }
    }
}

extension CurrencyListViewModelTests {
    final class Delegate: CurrencyListViewModelDelegate {
        var viewModelDidChangeCalled = false
        
        func viewModelDidChange(_ viewModel: CurrencyListViewModel) {
            viewModelDidChangeCalled = true
        }
    }
}
