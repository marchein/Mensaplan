//
//  File.swift
//  Mensa-Guthaben
//
//  Created by Georg on 16.08.19.
//  Copyright © 2019 Georg Sieber. All rights reserved.
//

import Foundation

class HistoryItem {
    var id : Int
    var balance : Double
    var lastTransaction : Double
    var date : String
    var cardID : String
    
    private var currencyFormatter: NumberFormatter {
        get {
            let valFormatter = NumberFormatter()
            valFormatter.numberStyle = .currency
            valFormatter.maximumFractionDigits = 2
            valFormatter.currencySymbol = "€"
            return valFormatter
        }
    }
    
    init(id:Int, balance:Double, lastTransaction: Double, date:String, cardID:String) {
        self.id = id
        self.balance = balance
        self.lastTransaction = lastTransaction
        self.date = date
        self.cardID = cardID
    }
    
    func getDate() -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy - HH:mm"
        return formatter.date(from: self.date)
    }
    
    func getDateString(short: Bool = false) -> String {
        if let date = self.getDate() {
            let formatter = DateFormatter()
            formatter.dateFormat = short ? "dd.MM.yyyy" : "dd.MM.yyyy - HH:mm"
            return formatter.string(from: date)
        }
        return "Kein Datum hinterlegt"
    }
    
    func getFormattedBalance() -> String {
        return currencyFormatter.string(from: NSNumber(value: balance))!
    }
    
    func getFormattedLastTransaction() -> String {
        return currencyFormatter.string(from: NSNumber(value: lastTransaction))!
    }
}
