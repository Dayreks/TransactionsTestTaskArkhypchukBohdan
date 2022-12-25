//
//  Utils .swift
//  TransactionsTestTaskArkhypchukBohdan
//
//  Created by Bohdan on 23.12.2022.
//

import Foundation


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

extension Double {
    
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}



struct C {
    
    static let numberOfLines = 3
    static let roundDecimal = 6
    static let fontSizeSub: CGFloat = 16
    static let fontSize: CGFloat = 24
    static let itemsPerPage = 20
    
    struct Constraints {
        static let xDistanceButtons: CGFloat = 8
        static let yDistanceButtons: CGFloat = 16
    }
}


