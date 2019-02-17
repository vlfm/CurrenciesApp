import Foundation

protocol CurrencyListViewModelDelegate: AnyObject {
    func viewModelDidChange(_ viewModel: CurrencyListViewModel)
}

final class CurrencyListViewModel {
    weak var delegate: CurrencyListViewModelDelegate?
    
    let title = NSLocalizedString("CurrencyList.Title", comment: "")
    
    var baseMoney: Money? {
        didSet {
            updateCurrencyCellViewModels()
        }
    }
    
    var currencyRates: CurrencyRates? {
        didSet {
            updateCurrencyCellViewModels()
        }
    }
    
    var updateAllowed: Producer<Bool> = { return true }
    
    private(set) var currencyCellViewModels: [CurrencyCellViewModel] = []
    
    private let baseMoneyInitialAmount = 100.0
    private let updateFrequency = 1.0
    
    private let currencyRateService: CurrencyRateService
    private let amountFormatter: NumberFormatter
    private let executor: Executor
    
    init(_ currencyRateService: CurrencyRateService,
         _ amountFormatter: NumberFormatter,
         _ executor: Executor = DispatchQueue.main) {
        self.currencyRateService = currencyRateService
        self.amountFormatter = amountFormatter
        self.executor = executor
    }
    
    func resume() {
        requestCurrencyRates(base: .eur)
    }
    
    func promoteToBaseCurrency(index: Int) {
        let vm = currencyCellViewModels.remove(at: index)
        currencyCellViewModels = [vm] + currencyCellViewModels
        baseMoney = vm.money
    }
    
    private func scheduleCurrencyRatesRequest() {
        let deadline = DispatchTime.now() + updateFrequency
        executor.execute(after: deadline) {
            if self.updateAllowed() {
                self.requestCurrencyRates(base: self.baseMoney?.currency)
            } else {
                self.scheduleCurrencyRatesRequest()
            }
        }
    }
    
    private func requestCurrencyRates(base: Currency?) {
        currencyRateService.queryCurrencyRates(base: nil) { [weak self] result in
            self?.executor.execute {
                self?.receiveCurrencyRates(result)
            }
        }
    }
    
    private func receiveCurrencyRates(_ result: Result<CurrencyRates>) {
        defer {
            scheduleCurrencyRatesRequest()
        }
        
        guard updateAllowed() else {
            return
        }
        
        do {
            currencyRates = try result.getValue()
        } catch {
            //
        }
    }
    
    private func updateCurrencyCellViewModels() {
        if let currencyRates = currencyRates {
            if currencyCellViewModels.isEmpty {
                updateCurrencyCellViewModelsInitial(with: currencyRates)
            }
            
            for vm in currencyCellViewModels {
                if let baseMoney = baseMoney, let money = currencyRates.convert(baseMoney, to: vm.money.currency) {
                    vm.money = money
                }
            }
            
            delegate?.viewModelDidChange(self)
        }
    }
    
    private func updateCurrencyCellViewModelsInitial(with currencyRates: CurrencyRates) {
        let baseCellViewModel = CurrencyCellViewModel(Money(baseMoneyInitialAmount,
                                                            currencyRates.base),
                                                      amountFormatter)
        currencyCellViewModels = [baseCellViewModel] +
            currencyRates.rates.keys
                .compactMap { currency in
                    return CurrencyCellViewModel(Money(0, currency), amountFormatter)
                }
                .sorted { a, b in
                    return a.money.currency.rawValue.lexicographicallyPrecedes(b.money.currency.rawValue)
        }
        baseMoney = Money(baseMoneyInitialAmount, currencyRates.base)
    }
}
