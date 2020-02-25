//
//  MealInterfaceController.swift
//  Watchapp Extension
//
//  Created by Marc Hein on 24.02.20.
//  Copyright © 2020 Marc Hein. All rights reserved.
//

import WatchKit
import Foundation
import SDWebImage


class MealInterfaceController: WKInterfaceController {
    @IBOutlet var mealTitleLabel: WKInterfaceLabel!
    @IBOutlet var mealPriceLabel: WKInterfaceLabel!
    @IBOutlet var mealImage: WKInterfaceImage!
    
    var meal: Meal? {
        didSet {
            guard let meal = meal else { return }
            
            mealTitleLabel.setText(meal.title)
            if let selectedPrice = UserDefaults.standard.string(forKey: LocalKeys.selectedPrice) {
                if selectedPrice == "student" {
                    mealPriceLabel.setText(meal.getFormattedPrice(price: meal.priceStudent))
                } else if selectedPrice == "worker" {
                    mealPriceLabel.setText(meal.getFormattedPrice(price: meal.priceWorker))
                } else if selectedPrice == "guest" {
                    mealPriceLabel.setText(meal.getFormattedPrice(price: meal.pricePublic))
                }
            }
            if let imageURL = meal.image {
                mealImage.sd_setImage(with: URL(string: imageURL), placeholderImage: UIImage(named: "watch-no-image-meal"))
            } else {
                mealImage.setImage(UIImage(named: "watch-no-image-meal"))
            }
        }
    }
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        if let meal = context as? Meal {
            self.meal = meal
        }
        
        
        // Configure interface objects here.
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    
    @IBAction func closeAction() {
        dismiss()
    }
    
}
