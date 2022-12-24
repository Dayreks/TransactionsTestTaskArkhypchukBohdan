//
//  ViewController.swift
//  TransactionsTestTaskArkhypchukBohdan
//
//  Created by Bohdan on 23.12.2022.
//

import UIKit

final class FirstScreen: UIViewController {
    
    @Fetch<Transaction> var transactions
    @Fetch<Balance> var balanceAmount
    
    private let balance = UILabel()
    private let rate = UILabel()
    
    private let topUp = UIButton()
    private let addTranscation = UIButton()
    
    private let historyTable = UITableView()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        historyTable.reloadData()
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        if CoreDataService.shared.fetch(Balance.self, predicate: nil) == [] {
            CoreDataService.shared.write {
                _ = CoreDataService.shared.create(Balance.self) { object in
                    object.amount = 0.0
                }
            }
        }
        
        view.backgroundColor = .systemBackground
        title = "Test Task"
        
        setUpBalance()
        setUpRate()
        setUpTopUp()
        setUpAddTransaction()
        setUpHistoryTable()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


//UI setUp with all the neccesary constraints and atributes
extension FirstScreen {
    
    func setUpBalance() {
        view.addSubview(balance)
        
        guard let balanceAmount = balanceAmount.first?.amount else {return}
        balance.text = "\(balanceAmount) btc"
        balance.numberOfLines = 3
        balance.font = .systemFont(ofSize: 24)
        
        balance.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            balance.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            balance.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 8),
            balance.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5)
        ])
        
        
    }
    
    func setUpRate() {
        view.addSubview(rate)
        
        rate.text = "1 btc = xxxxxxx.xxx $"
        rate.numberOfLines = 3
        rate.font = .systemFont(ofSize: 16)
        
        rate.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            rate.centerYAnchor.constraint(equalTo: balance.centerYAnchor, constant: 4),
            rate.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -8),
            rate.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5)
        ])
    }
    
    func setUpTopUp() {
        view.addSubview(topUp)
        
        topUp.configuration = .filled()
        topUp.configuration?.title = "Top Up"
        topUp.configuration?.baseBackgroundColor = .secondarySystemBackground
        topUp.configuration?.baseForegroundColor = .secondaryLabel
        
        topUp.addTarget(self, action: #selector(topUpBalance), for: .touchUpInside)
        
        topUp.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            topUp.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 8),
            topUp.topAnchor.constraint(equalTo: balance.bottomAnchor, constant: 8)
        ])
        
    }
    
    func setUpAddTransaction() {
        view.addSubview(addTranscation)
        
        addTranscation.configuration = .filled()
        addTranscation.configuration?.title = "Add Transaction"
        addTranscation.configuration?.baseBackgroundColor = .secondarySystemBackground
        addTranscation.configuration?.baseForegroundColor = .secondaryLabel
        
        addTranscation.addTarget(self, action: #selector(nextScreen), for: .touchUpInside)
        
        addTranscation.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            addTranscation.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            addTranscation.topAnchor.constraint(equalTo: topUp.bottomAnchor, constant: 8)
        ])
    }
    
    func setUpHistoryTable() {
        view.addSubview(historyTable)
        
        historyTable.backgroundColor = .secondarySystemBackground
        
        
        historyTable.register(TransactionCell.self, forCellReuseIdentifier: "transaction.id")
        historyTable.dequeueReusableCell(withIdentifier: "transaction.id")
        
        historyTable.delegate = self
        historyTable.dataSource = self
        
        historyTable.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            historyTable.topAnchor.constraint(equalTo: addTranscation.bottomAnchor, constant: 8),
            historyTable.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            historyTable.leftAnchor.constraint(equalTo: view.leftAnchor),
            historyTable.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
        
    }
    
}

extension FirstScreen: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return transactions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "transaction.id", for: indexPath) as! TransactionCell
        cell.isUserInteractionEnabled = false
        cell.transcation = transactions[indexPath.row]
        cell.configure()
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            CoreDataService.shared.write {
                CoreDataService.shared.delete(transactions[indexPath.row])
            }
            historyTable.reloadData()
        }
    }
}


//Actions for the buttons 
extension FirstScreen {
    
    @objc func nextScreen() {
        let nextScreen = SecondScreen()
        nextScreen.title = "New Transaction"
        navigationController?.pushViewController(nextScreen, animated: true)
        
    }
    
    @objc func topUpBalance() {
        let topUpAlert = UIAlertController(title: "Top Up", message: "Enter the amount in BTC", preferredStyle: .alert)
        topUpAlert.addTextField()
        topUpAlert.textFields?.first?.keyboardType = .decimalPad
        
        topUpAlert.addAction(.init(title: "Submit", style: .default) { [weak self] _ in
            if let amount = topUpAlert.textFields?.first?.text {
                
                CoreDataService.shared.write {
                    
                    let balance = CoreDataService.shared.fetch(Balance.self, predicate: nil)
                    guard let currentBalance = balance.first?.amount, let amount = Double(amount) else {return}
                    balance.first?.amount = currentBalance + amount
                    
                    _ = CoreDataService.shared.create(Transaction.self) { object in
                        object.amount = amount
                        object.category = "top up"
                        object.date = .init()
                    }
                }
                
                guard let balanceAmount = self?.balanceAmount.first?.amount else {return}
                self?.balance.text = "\(balanceAmount) btc"
                
                self?.historyTable.reloadData()
            }
        })
        
        present(topUpAlert, animated: false)
    }
}

