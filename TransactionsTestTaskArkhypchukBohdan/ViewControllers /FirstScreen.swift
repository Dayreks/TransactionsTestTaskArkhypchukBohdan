//
//  ViewController.swift
//  TransactionsTestTaskArkhypchukBohdan
//
//  Created by Bohdan on 23.12.2022.
//

import UIKit
import CoreData

final class FirstScreen: UIViewController {
    @Fetch<Transaction> var transactions
    @Fetch<Balance> var balanceAmount
    private var sortedTransactions: [Transaction] = []
    private var isPaginationOn = false
    private var rateValue: String?
    private let balance = UILabel()
    private let rate = UILabel()
    private let topUp = UIButton()
    private let addTranscation = UIButton()
    private let historyTable = UITableView()
    private var lastUpdateTime: Date?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(checkIfNeededToUpdate),
                                               name: UIApplication.willEnterForegroundNotification,
                                               object: nil)
        gainRateValue()
        loadMore(itemsPerPage: C.itemsPerPage, currentPage: _transactions.currentPage)
        if CoreDataService.shared.fetch(Balance.self).isEmpty { // Setup of the initial balance in case it was not set already
            CoreDataService.shared.write {
                _ = CoreDataService.shared.create(Balance.self) { object in
                    object.amount = 0.0
                }
            }
        }
        view.backgroundColor = .systemBackground
        title = C.Strings.firstScreenTitle
        setUpBalance() // Preparing all of the UI elements
        setUpTopUp()
        setUpRate()
        setUpAddTransaction()
        setUpHistoryTable()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension FirstScreen: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sortedTransactions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: C.Strings.cellId, for: indexPath) as? TransactionCell
        guard let cell = cell else {return UITableViewCell()}
        cell.isUserInteractionEnabled = false
        cell.transcation = sortedTransactions[indexPath.row]
        cell.configure()
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pos = scrollView.contentOffset.y
        if pos > historyTable.contentSize.height - C.Constraints.yDistanceButtons - scrollView.frame.size.height,
           !isPaginationOn {
            _transactions.currentPage += 1
            isPaginationOn = true
            loadMore(itemsPerPage: C.itemsPerPage, currentPage: _transactions.currentPage)
        }
    }
}


extension FirstScreen {
    private func loadMore(itemsPerPage: Int, currentPage: Int) {
        let newData = CoreDataService.shared.fetchBatch(Transaction.self,
                                                        itemsPerPage: itemsPerPage,
                                                        currentPage: currentPage)
        guard !newData.isEmpty else { return }
        sortedTransactions.append(contentsOf: newData)
        sortedTransactions.sort(by: {$0.date! > $1.date!})
        historyTable.reloadData()
        if isPaginationOn {
            isPaginationOn = false
        }
    }
    
    @objc private func nextScreen() {
        let nextScreen = SecondScreen()
        nextScreen.delegate = self
        nextScreen.title = C.Strings.secondScreenTitle
        navigationController?.pushViewController(nextScreen, animated: true)
    }
    
    @objc private func topUpBalance() {
        let topUpAlert = UIAlertController(title: "Top Up",
                                           message: C.Strings.amountOfBtcMessage,
                                           preferredStyle: .alert)
        topUpAlert.addTextField()
        topUpAlert.textFields?.first?.keyboardType = .decimalPad
        let balance = CoreDataService.shared.fetch(Balance.self)
        guard let currentBalance = balance.first?.amount else {return}
        topUpAlert.addAction(.init(title: "Submit", style: .default) { [weak self] _ in
            if let amount = topUpAlert.textFields?.first?.text, let amountValue = Double(amount) {
                CoreDataService.shared.write {
                    balance.first?.amount = currentBalance.rounded(toPlaces: C.roundDecimal) +
                                            amountValue.rounded(toPlaces: C.roundDecimal) // Changing balance amount to the according input
                    _ = CoreDataService.shared.create(Transaction.self) { object in  // Adding new transaction of a type "top up"
                        object.amount = amountValue
                        object.category = C.Strings.topUp
                        object.date = .init()
                    }
                }
                guard let balanceAmount = self?.balanceAmount.first?.amount else { return }
                self?.balance.text = "\(balanceAmount) btc"
                self?.addTransaction()
                self?.historyTable.reloadData()
            } else {
                let wrongFormat = UIAlertController(title: "Error",
                                                    message: C.Strings.wrongValueMessage,
                                                    preferredStyle: .alert) // If there is a wrong input showing the user that error
                self?.present(wrongFormat, animated: true, completion: {
                    wrongFormat.view.superview?.isUserInteractionEnabled = true
                    wrongFormat.view.superview?.addGestureRecognizer(UITapGestureRecognizer(
                        target: self,
                        action: #selector(self?.dismissOnTapOutside)
                    ))
                })
            }
        })
        present(topUpAlert, animated: false)
    }
    
    @objc private func dismissOnTapOutside() {
        self.dismiss(animated: true, completion: nil)
    }
    
    private func gainRateValue() {
        Task {
            if let rateValue = await RateData().getRate() {
                DispatchQueue.main.async { [weak self] in
                    self?.rateValue = rateValue
                    self?.rate.text = "1 btc = \(rateValue) $"
                }
            }
        }
        self.lastUpdateTime = .init()
    }
    
    @objc private func checkIfNeededToUpdate() {
        guard let lastUpdateTime = lastUpdateTime else {return}
        if Date().timeIntervalSince(lastUpdateTime) >= 3600 {
            gainRateValue()
        }
    }
}

extension FirstScreen: SecondScreenDelegate {
    func addTransaction() {
        loadMore(itemsPerPage: 1, currentPage: 1)
        guard let balanceAmount = balanceAmount.first?.amount else {return}
        balance.text = "\(balanceAmount.rounded(toPlaces: C.roundDecimal)) btc"
        historyTable.reloadData()
    }
}

extension FirstScreen { // UI setUp with all the neccesary constraints and atributes
    private func setUpBalance() {
        view.addSubview(balance)
        guard let balanceAmount = balanceAmount.first?.amount else {return}
        balance.text = "\(balanceAmount.rounded(toPlaces: C.roundDecimal)) btc"
        balance.numberOfLines = C.numberOfLines
        balance.font = .systemFont(ofSize: C.fontSize)
        balance.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            balance.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,
                                         constant: C.Constraints.yDistanceButtons),
            balance.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor,
                                          constant: C.Constraints.xDistanceButtons),
            balance.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5)
        ])
    }
    
    private func setUpTopUp() {
        view.addSubview(topUp)
        topUp.configuration = .filled()
        topUp.configuration?.title = C.ViewNames.topUp
        topUp.configuration?.baseBackgroundColor = .secondarySystemBackground
        topUp.configuration?.baseForegroundColor = .secondaryLabel
        topUp.addTarget(self, action: #selector(topUpBalance), for: .touchUpInside)
        topUp.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            topUp.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor,
                                        constant: C.Constraints.xDistanceButtons),
            topUp.topAnchor.constraint(equalTo: balance.bottomAnchor, constant: C.Constraints.yDistanceButtons)
        ])
    }
    
    private func setUpRate() {
        view.addSubview(rate)
        rate.numberOfLines = C.numberOfLines
        rate.textColor = .systemGray
        rate.font = .systemFont(ofSize: C.fontSizeSub)
        rate.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            rate.centerYAnchor.constraint(equalTo: topUp.centerYAnchor),
            rate.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor,
                                        constant: -C.Constraints.xDistanceButtons),
        ])
    }
    
    private func setUpAddTransaction() {
        view.addSubview(addTranscation)
        addTranscation.configuration = .filled()
        addTranscation.configuration?.title = C.ViewNames.addTransaction
        addTranscation.configuration?.baseBackgroundColor = .secondarySystemBackground
        addTranscation.configuration?.baseForegroundColor = .secondaryLabel
        addTranscation.addTarget(self, action: #selector(nextScreen), for: .touchUpInside)
        addTranscation.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            addTranscation.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            addTranscation.topAnchor.constraint(equalTo: topUp.bottomAnchor, constant: C.Constraints.yDistanceButtons)
        ])
    }
    
    private func setUpHistoryTable() {
        view.addSubview(historyTable)
        historyTable.backgroundColor = .secondarySystemBackground
        historyTable.register(TransactionCell.self, forCellReuseIdentifier: C.Strings.cellId)
        historyTable.dequeueReusableCell(withIdentifier: C.Strings.cellId)
        historyTable.delegate = self
        historyTable.dataSource = self
        historyTable.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            historyTable.topAnchor.constraint(equalTo: addTranscation.bottomAnchor,
                                              constant: C.Constraints.yDistanceButtons),
            historyTable.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            historyTable.leftAnchor.constraint(equalTo: view.leftAnchor),
            historyTable.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
    }
}
