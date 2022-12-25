//
//  SecondScreen.swift
//  TransactionsTestTaskArkhypchukBohdan
//
//  Created by Bohdan on 23.12.2022.
//

import UIKit


final class SecondScreen: UIViewController {
    
    private let amountLabel = UILabel()
    private let amountField = UITextField()
    private let categoryPicker = UIPickerView()
    private let addButton = UIButton()
    
    weak var delegate: SecondScreenDelegate?
    
    
    let cases = Category.allCases.map { $0.rawValue }
    private var category: String! = Category.groceries.rawValue
    private var amount: Double!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tap)
        
        //Initial setup of the UI for the ViewController
        setUpAmountLabel()
        setUpAmountField()
        setUpCategoryPicker()
        setUpAddButton()
    }
    
}

extension SecondScreen {
    
    func setUpAmountLabel() {
        
        view.addSubview(amountLabel)
        
        amountLabel.text = C.ViewNames.amount
        amountLabel.font = .systemFont(ofSize: C.fontSizeSub)
        
        amountLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            amountLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            amountLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: C.Constraints.yDistanceButtons)
        ])
    }
    
    func setUpAmountField(){
        
        view.addSubview(amountField)
        
        amountField.placeholder = "Enter the amount here"
        amountField.font = .systemFont(ofSize: C.fontSizeSub)
        amountField.textAlignment = .center
        amountField.keyboardType = .decimalPad
        
        amountField.delegate = self
        
        amountField.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            amountField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            amountField.topAnchor.constraint(equalTo: amountLabel.bottomAnchor, constant: C.Constraints.yDistanceButtons)
        ])
    }
    
    func setUpCategoryPicker() {
        
        view.addSubview(categoryPicker)
        
        categoryPicker.dataSource = self
        categoryPicker.delegate = self
        
        categoryPicker.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            categoryPicker.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            categoryPicker.topAnchor.constraint(equalTo: amountField.bottomAnchor, constant: C.Constraints.yDistanceButtons)
        ])
    }
    
    func setUpAddButton() {
        view.addSubview(addButton)
        
        addButton.configuration = .filled()
        addButton.configuration?.title = C.ViewNames.add
        addButton.configuration?.baseBackgroundColor = .secondarySystemBackground
        addButton.configuration?.baseForegroundColor = .secondaryLabel
        
        addButton.addTarget(self, action: #selector(addTransaction), for: .touchUpInside)
        
        addButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            addButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            addButton.topAnchor.constraint(equalTo: categoryPicker.bottomAnchor, constant: C.Constraints.yDistanceButtons)
        ])
    }
    
    
    @objc func addTransaction() {
        
        let balance = CoreDataService.shared.fetch(Balance.self)
        guard let currentBalance = balance.first?.amount else {return}
        
        if let amount = self.amount {
            
            //Checking whether the user can perform transaction based on their current balance
            if (currentBalance >= amount) {
                
                //Creating new transaction
                CoreDataService.shared.write{
                    _ = CoreDataService.shared.create(Transaction.self) { object in
                        object.amount = -amount
                        object.category = self.category
                        object.date = .init()
                    }
                    
                    //Deducting the amount of the transaction from the balance accordingly
                    balance.first?.amount = currentBalance.rounded(toPlaces: C.roundDecimal) - amount.rounded(toPlaces: C.roundDecimal)
                    
                    navigationController?.popToRootViewController(animated: true)
                }
                
                delegate?.addTransaction()
                
            } else {
                
                //If there are not enough money on the balance showing this error
                let notEnoughMoney = UIAlertController(title: "Oops", message: C.Strings.wrongAmountMessage, preferredStyle: .alert)
                present(notEnoughMoney, animated: true, completion:{
                    notEnoughMoney.view.superview?.isUserInteractionEnabled = true
                    notEnoughMoney.view.superview?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.dismissOnTapOutside)))
                })
            }
            
        } else {
            
            //If there is a wrong input showing the user that error
            let wrongFormat = UIAlertController(title: "Error", message: C.Strings.wrongValueMessage, preferredStyle: .alert)
            present(wrongFormat, animated: true, completion:{
                wrongFormat.view.superview?.isUserInteractionEnabled = true
                wrongFormat.view.superview?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.dismissOnTapOutside)))
            })
        }
        
        
    }
    
    @objc func dismissOnTapOutside(){
        self.dismiss(animated: true, completion: nil)
    }
}

extension SecondScreen: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int { return 1 }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int { return 5 }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? { return cases[row] }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) { category = cases[row] }
}

extension SecondScreen: UITextFieldDelegate {
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text, let textRange = Range(range, in: text) {
            let updatedText = text.replacingCharacters(in: textRange, with: string)
            amount = Double(updatedText)
        }
        return true
        
    }
    
}
