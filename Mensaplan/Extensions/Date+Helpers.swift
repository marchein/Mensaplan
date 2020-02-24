//
//  Date+Helpers.swift
//  myTodo
//
//  Created by Marc Hein on 20.11.18.
//  Copyright © 2018 Marc Hein Webdesign. All rights reserved.
//

import Foundation

extension Date {
    func addedBy(minutes: Int) -> Date {
        return Calendar.current.date(byAdding: .minute, value: minutes, to: self)!
    }
    
    func dateBy(date: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter.date(from: date)
    }
    
    static func getCurrentDate() -> String {
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "dd.MM.yyyy - HH:mm"
        return dateformatter.string(from: Date())
    }
}
