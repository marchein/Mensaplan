//
//  Data.swift
//  Mensaplan
//
//  Created by Marc Hein on 20.10.19.
//  Copyright © 2019 Marc Hein. All rights reserved.
//

import Foundation

struct Mensaplan: Decodable {
    let days: [Location]
    
    enum CodingKeys : String, CodingKey {
        case days = "plan"
    }
}

struct Location: Decodable {
    let location: [LocationDay]
    
    enum CodingKeys : String, CodingKey {
        case location
    }
}

struct LocationDay: Decodable {
    let data: MensaplanDay
    let date: Int
    let title: String
    
    enum CodingKeys : String, CodingKey {
        case date
        case data
        case title
    }
    
    func getDate(showDay: Bool = true) -> String? {
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyyMMdd"

        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "dd.MM.yyyy"

        if let date = dateFormatterGet.date(from: "\(self.date)") {
            var resultString = dateFormatterPrint.string(from: date)
            if showDay {
                if Calendar.current.isDateInYesterday(date) {
                    resultString = "\(resultString) - (Gestern)"
                } else if Calendar.current.isDateInToday(date) {
                    resultString = "\(resultString) - (Heute)"
                } else if Calendar.current.isDateInTomorrow(date) {
                    resultString = "\(resultString) - (Morgen)"
                }
            }
            return  resultString
        } else {
           print("There was an error decoding the string")
        }
        return nil
    }
}

struct MensaplanDay: Decodable {
    let date: Int
    let counters: [Counter]
    
    enum CodingKeys : String, CodingKey {
        case date
        case counters
    }
    
    func getDate(showDay: Bool = true) -> String? {
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyyMMdd"

        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "dd.MM.yyyy"

        if let date = dateFormatterGet.date(from: "\(self.date)") {
            var resultString = dateFormatterPrint.string(from: date)
            if showDay {
                if Calendar.current.isDateInYesterday(date) {
                    resultString = "\(resultString) - (Gestern)"
                } else if Calendar.current.isDateInToday(date) {
                    resultString = "\(resultString) - (Heute)"
                } else if Calendar.current.isDateInTomorrow(date) {
                    resultString = "\(resultString) - (Morgen)"
                }
            }
            return  resultString
        } else {
           print("There was an error decoding the string")
        }
        return nil
    }
}

struct Counter: Decodable {
    let label: String
    let meals: [Meal]
    
    enum CodingKeys : String, CodingKey {
       case label
       case meals
   }
}

struct Meal: Decodable {
    let title: String
    let priceStudent: Double
     let priceWorker: Double
     let pricePublic: Double
    
    enum CodingKeys : String, CodingKey {
        case title
        case priceStudent
        case priceWorker
        case pricePublic
    }
    
    func getFormattedPrice(price: Double) -> String? {
        return String(format: "%.02f€", price)
    }
}
