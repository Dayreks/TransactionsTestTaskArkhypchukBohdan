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
    
    
    let cases = Category.allCases.map { $0.rawValue }
    private var category: String! = Category.groceries.rawValue
    private var amount: Double!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tap)
        
        setUpAmountLabel()
        setUpAmountField()
        setUpCategoryPicker()
        setUpAddButton()
    }
    
}

extension SecondScreen {
    
    func setUpAmountLabel() {
        
        view.addSubview(amountLabel)
        
        amountLabel.text = "Amount"
        amountLabel.font = .systemFont(ofSize: 16)
        
        amountLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            amountLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            amountLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 160)
        ])
    }
    
    func setUpAmountField(){
        
        view.addSubview(amountField)
        
        amountField.placeholder = "Enter the amount here"
        amountField.font = .systemFont(ofSize: 16)
        amountField.textAlignment = .center
        amountField.keyboardType = .decimalPad
        
        amountField.delegate = self

        amountField.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            amountField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            amountField.topAnchor.constraint(equalTo: amountLabel.bottomAnchor, constant: 16)
        ])
    }
    
    func setUpCategoryPicker() {
        
        view.addSubview(categoryPicker)
        
        categoryPicker.dataSource = self
        categoryPicker.delegate = self
        
        categoryPicker.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            categoryPicker.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            categoryPicker.topAnchor.constraint(equalTo: amountField.bottomAnchor, constant: 8)
        ])
    }
    
    func setUpAddButton() {
        view.addSubview(addButton)
        
        addButton.configuration = .filled()
        addButton.configuration?.title = "Add"
        addButton.configuration?.baseBackgroundColor = .secondarySystemBackground
        addButton.configuration?.baseForegroundColor = .secondaryLabel
        
        addButton.addTarget(self, action: #selector(addTransaction), for: .touchUpInside)
        
        addButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            addButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            addButton.topAnchor.constraint(equalTo: categoryPicker.bottomAnchor, constant: 8)
        ])
    }
    
    
    @objc func addTransaction() {
        if let amount = self.amount {
            CoreDataService.shared.write{
                _ = CoreDataService.shared.create(Transaction.self) { object in
                    object.amount = -amount
                    object.category = self.category
                    object.date = .init()
                }
            }
        } else {
            let wrongFormat = UIAlertController(title: "Error", message: "The amount is either nil or in the wrong format", preferredStyle: .alert)
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
        guard let number = textField.text else {return false}
        amount = Double(number)
        return true
    }

}
