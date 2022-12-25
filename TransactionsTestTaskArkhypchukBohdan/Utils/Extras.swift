//
//  Utils .swift
//  TransactionsTestTaskArkhypchukBohdan
//
//  Created by Bohdan on 23.12.2022.
//

import Foundation


protocol SecondScreenDelegate: AnyObject {
    func addTransaction()
}


extension Double {
    
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

enum Category: String, CaseIterable {
    case groceries
    case taxi
    case electronics
    case restaurant
    case `other`
}


enum NetworkError: Error {
    
    case badHostString
    case bad
    
}


enum C {
    
    
    static let numberOfLines = 3
    static let roundDecimal = 6
    static let fontSizeSub: CGFloat = 16
    static let fontSize: CGFloat = 24
    static let itemsPerPage = 20
    
    enum Constraints {
        static let xDistanceButtons: CGFloat = 8
        static let yDistanceButtons: CGFloat = 16
    }
    
    enum Strings {
        static let topUp = "top up"
        static let url = "https://api.coindesk.com/v1/bpi/currentprice.json"
        static let cellId = "transaction.id"
        static let wrongValueMessage = "The amount is either nil or in the wrong format"
        static let wrongAmountMessage = "You are too poor to do this :("
        static let dateFormat = "d.MM.yyyy HH:mm"
        static let amountOfBtcMessage = "Enter the amount in BTC"
        static let firstScreenTitle = "Test Task"
        static let secondScreenTitle = "New Transaction"
    }
    
    enum ViewNames {
        static let topUp = "Top Up"
        static let addTransaction = "Add Transaction"
        static let add = "Add"
        static let amount = "Amount"
    }
}




