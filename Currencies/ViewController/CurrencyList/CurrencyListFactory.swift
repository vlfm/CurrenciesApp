import UIKit

final class CurrencyListFactory {
    let storyboard = UIStoryboard(name: "CurrencyList", bundle: nil)
    
    func make(with context: AppContext) -> UIViewController {
        let vc = storyboard.instantiateViewController(withIdentifier: "CurrencyList") as! CurrencyListViewController
        vc.currencyRateService = context.currencyRateService
        return vc
    }
}
