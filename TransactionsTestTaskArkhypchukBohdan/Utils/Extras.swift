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

extension Double {
   
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
