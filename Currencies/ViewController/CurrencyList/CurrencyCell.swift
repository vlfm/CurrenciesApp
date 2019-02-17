import UIKit

final class CurrencyCell: UITableViewCell {
    static let reuseIdentifier = "CurrencyCell"
    
    @IBOutlet private var countryFlagImageView: UIImageView!
    @IBOutlet private var currencyIdLabel: UILabel!
    @IBOutlet private var currencyNameLabel: UILabel!
    
    @IBOutlet private var amountTextField: UITextField! {
        didSet {
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(textFieldDidChange(_:)),
                                                   name: UITextField.textDidChangeNotification,
                                                   object: amountTextField)
        }
    }
    
    @IBOutlet private var underTextLineView: UIView!
    
    var viewModel: CurrencyCellViewModel? {
        didSet {
            if let viewModel = viewModel {
                viewModel.delegate = self
                update(from: viewModel)
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        viewModel?.delegate = nil
        underTextLineView.backgroundColor = .lightGray
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override func becomeFirstResponder() -> Bool {
        amountTextField.isUserInteractionEnabled = true
        return amountTextField.becomeFirstResponder()
    }
    
    @objc private func textFieldDidChange(_ notification: Notification) {
        viewModel?.amountDidChange(amountTextField.text)
    }
}

extension CurrencyCell {
    private func update() {
        if let vm = viewModel {
            update(from: vm)
        }
    }
    
    private func update(from viewModel: CurrencyCellViewModel) {
        countryFlagImageView.image = UIImage(named: viewModel.countryFlagImageName)
        currencyIdLabel.text = viewModel.currencyId
        currencyNameLabel.text = viewModel.currencyName
        
        if !amountTextField.isEditing {
            amountTextField.text = viewModel.amount
        }
    }
}

extension CurrencyCell: CurrencyCellViewModelDelegate {
    func viewModelDidChange(_ viewModel: CurrencyCellViewModel) {
        update(from: viewModel)
    }
}

extension CurrencyCell: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        underTextLineView.backgroundColor = UIColor(red: 33.0 / 255.0,
                                                    green: 133.0 / 255.0,
                                                    blue: 206.0 / 255.0,
                                                    alpha: 1.0)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.isUserInteractionEnabled = false
        underTextLineView.backgroundColor = .lightGray
        update()
    }
}
