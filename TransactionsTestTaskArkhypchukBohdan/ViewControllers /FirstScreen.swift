//
//  ViewController.swift
//  TransactionsTestTaskArkhypchukBohdan
//
//  Created by Bohdan on 23.12.2022.
//

import UIKit

final class FirstScreen: UIViewController, UITableViewDelegate {
    
    private let balance = UILabel()
    private let rate = UILabel()
    
    private let topUp = UIButton()
    private let addTranscation = UIButton()
    
    private let historyTable = UITableView()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        title = "Test Task"
        
        setUpBalance()
        setUpRate()
        setUpTopUp()
        setUpAddTransaction()
        setUpHistoryTable()
    }
    
    
}


//UI setUp with all the neccesary constraints and atributes
extension FirstScreen {
    
    func setUpBalance() {
        view.addSubview(balance)
        
        balance.text = "0.0 btc"
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
        
        
        historyTable.register(UITableViewCell.self, forCellReuseIdentifier: "transaction.id")
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
    
    
    @objc func nextScreen() {
        let nextScreen = SecondScreen()
        nextScreen.title = "New Transaction"
        navigationController?.pushViewController(nextScreen, animated: true)
        
    }
    
}

extension FirstScreen: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "transaction.id", for: indexPath)
        cell.isUserInteractionEnabled = false
        return cell
    }
}

