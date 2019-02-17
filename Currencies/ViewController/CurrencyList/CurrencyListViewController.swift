import UIKit

final class CurrencyListViewController: UIViewController {
    @IBOutlet var tableView: UITableView!
    
    var currencyRateService: CurrencyRateService!
    
    private var viewModel: CurrencyListViewModel!
    private var isLoaded = false
    
    private var movingUpIndexPath: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let amountFormatter = NumberFormatter()
        amountFormatter.minimumIntegerDigits = 1
        amountFormatter.maximumFractionDigits = 2
        amountFormatter.minimumFractionDigits = 2
        
        viewModel = CurrencyListViewModel(currencyRateService, amountFormatter)
        
        title = viewModel.title
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(moneyDidChange(notification:)),
                                               name: CurrencyCellViewModel.moneyDidChangeNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardDidChangeFrame(notification:)),
                                               name: UIResponder.keyboardWillChangeFrameNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide(notification:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
        
        viewModel.delegate = self
        
        viewModel.updateAllowed = { [weak self] in
            if let tableView = self?.tableView {
                return !tableView.isDragging && !tableView.isDecelerating
            }
            return true
        }
        
        viewModel.resume()
    }
    
    @objc private func keyboardDidChangeFrame(notification: Notification) {
        guard let userInfo = notification.userInfo else {
            return
        }
        
        guard let keyboardScreenEndFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
        
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        
        tableView.contentInset.bottom = keyboardViewEndFrame.height
        tableView.scrollIndicatorInsets.bottom = keyboardViewEndFrame.height
    }
    
    @objc private func keyboardWillHide(notification: Notification) {
        tableView.contentInset.bottom = 0
        tableView.scrollIndicatorInsets.bottom = 0
    }
    
    @objc private func moneyDidChange(notification: Notification) {
        if let money = notification.userInfo?[CurrencyCellViewModel.moneyUserInfoKey] as? Money {
            viewModel.baseMoney = money
        }
    }
}

extension CurrencyListViewController: CurrencyListViewModelDelegate {
    func viewModelDidChange(_ viewModel: CurrencyListViewModel) {
        if !isLoaded {
            isLoaded = true
            tableView.reloadData()
        }
    }
}

extension CurrencyListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.currencyCellViewModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: CurrencyCell.reuseIdentifier,
                                                 for: indexPath) as! CurrencyCell
        cell.viewModel = viewModel.currencyCellViewModels[indexPath.row]
        return cell
    }
}

extension CurrencyListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.contentOffset.y > 0 {
            let zeroIndexPath = IndexPath(row: 0, section: 0)
            movingUpIndexPath = indexPath
            tableView.scrollToRow(at: zeroIndexPath, at: .top, animated: true)
        } else {
            moveToTopAndBecomeFirstResponderItem(at: indexPath)
        }
    }
}

extension CurrencyListViewController: UIScrollViewDelegate {
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        if let indexPath = movingUpIndexPath {
            moveToTopAndBecomeFirstResponderItem(at: indexPath)
        }
        movingUpIndexPath = nil
    }
    
    private func moveToTopAndBecomeFirstResponderItem(at indexPath: IndexPath) {
        let zeroIndexPath = IndexPath(row: 0, section: 0)
        
        viewModel.promoteToBaseCurrency(index: indexPath.row)
        
        if tableView.indexPathsForVisibleRows?.contains(indexPath) ?? false {
            tableView.moveRow(at: indexPath, to: zeroIndexPath)
            if let cell = self.tableView.cellForRow(at: zeroIndexPath) {
                cell.becomeFirstResponder()
            }
        } else {
            tableView.performBatchUpdates({
                tableView.deleteRows(at: [indexPath], with: .automatic)
                tableView.insertRows(at: [zeroIndexPath], with: .fade)
            }) { _ in
                if let cell = self.tableView.cellForRow(at: zeroIndexPath) {
                    cell.becomeFirstResponder()
                }
            }
        }
    }
}
