//
//  Data.swift
//  Mensaplan
//
//  Created by Marc Hein on 20.10.19.
//  Copyright © 2019 Marc Hein. All rights reserved.
//

import Foundation

struct Mensaplan: Decodable {
    let days: [MensaplanDay]
    
    enum CodingKeys : String, CodingKey {
        case days = "plan"
    }
}

struct MensaplanDay: Decodable {
    let date: Int
    let counters: [Counter]
    
    enum CodingKeys : String, CodingKey {
        case date
        case counters
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
    let price: Float
    
    enum CodingKeys : String, CodingKey {
        case title
        case price
    }
}
