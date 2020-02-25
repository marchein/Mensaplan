//
//  MealRowController.swift
//  Mensaplan
//
//  Created by Marc Hein on 24.02.20.
//  Copyright © 2020 Marc Hein. All rights reserved.
//

import WatchKit

class MealRowController: NSObject {
    @IBOutlet var titleLabel: WKInterfaceLabel!
    @IBOutlet var priceLabel: WKInterfaceLabel!
    
    var meal: Meal? {
        didSet {
            guard let meal = meal else { return }
            
            titleLabel.setText(meal.title)
            
            if let selectedPrice = UserDefaults.standard.string(forKey: LocalKeys.selectedPrice) {
                if selectedPrice == "student" {
                    priceLabel.setText(meal.getFormattedPrice(price: meal.priceStudent))
                } else if selectedPrice == "worker" {
                    priceLabel.setText(meal.getFormattedPrice(price: meal.priceWorker))
                } else if selectedPrice == "guest" {
                    priceLabel.setText(meal.getFormattedPrice(price: meal.pricePublic))
                }
            }
        }
    }
}
