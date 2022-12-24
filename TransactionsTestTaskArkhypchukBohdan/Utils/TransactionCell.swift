//
//  TransactionCell.swift
//  TransactionsTestTaskArkhypchukBohdan
//
//  Created by Bohdan on 24.12.2022.
//

import UIKit

final class TransactionCell: UITableViewCell {
    
    var transcation: Transaction?
    
    private let view = UIView()
    
    private let amount = UILabel()
    private let date = UILabel()
    private let category = UILabel()
    
    //Configuration of the cell's views
    func configure() {
        setUpAmount()
        setUpDate()
        setUpCategory()
    }
}

extension TransactionCell {
    
    func setUpAmount() {
        contentView.addSubview(amount)
        
        guard let amountBTC = transcation?.amount else {return}
        amount.text = "\(amountBTC.rounded(toPlaces: 3)) btc"
        amount.numberOfLines = 3
        amount.font = .systemFont(ofSize: 16)
        
        amount.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            amount.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            amount.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 8)
        ])
    }
    
    func setUpDate() {
        contentView.addSubview(date)
        
       
        let formatter = DateFormatter()
        formatter.dateFormat = "d.MM.yyyy HH:mm "
        guard let transcationDate = transcation?.date else {return}
        let formattedDate = formatter.string(from: transcationDate)
        
        date.text = formattedDate
        date.numberOfLines = 3
        date.font = .systemFont(ofSize: 16)
        
        date.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            date.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            date.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
        ])
    }
    
    func setUpCategory() {
        contentView.addSubview(category)
        
        guard let categoryText = transcation?.category else {return}
        category.text = "\(categoryText)"
        category.numberOfLines = 3
        category.font = .systemFont(ofSize: 16)
        
        category.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            category.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            category.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -8)
        ])
    }
}
