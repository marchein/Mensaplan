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
    @IBOutlet var mealStudentPriceLabel: WKInterfaceLabel!
    @IBOutlet var mealWorkerPriceLabel: WKInterfaceLabel!
    @IBOutlet var mealPublicPriceLabel: WKInterfaceLabel!
    @IBOutlet var imageGroup: WKInterfaceGroup!
    @IBOutlet var mealImage: WKInterfaceImage!
    @IBOutlet var informationGroup: WKInterfaceGroup!
    @IBOutlet var informationTable: WKInterfaceTable!
    @IBOutlet var stoffTable: WKInterfaceTable!
    
    var meal: Meal? {
        didSet {
            guard let meal = meal else { return }
            
            mealTitleLabel.setText(meal.title)
            mealStudentPriceLabel.setText(meal.getFormattedPrice(price: meal.priceStudent))
            mealWorkerPriceLabel.setText(meal.getFormattedPrice(price: meal.priceWorker))
            mealPublicPriceLabel.setText(meal.getFormattedPrice(price: meal.pricePublic))
            
            let globalDefaults = UserDefaults(suiteName: MensaplanApp.groupIdentifier)!
            
            if globalDefaults.bool(forKey: "show_images") {
                imageGroup.setHidden(false)
                if let imageURL = meal.image {
                    mealImage.sd_setImage(with: URL(string: imageURL), placeholderImage: UIImage(named: "watch-no-image-meal"))
                } else {
                    mealImage.setImage(UIImage(named: "watch-no-image-meal"))
                }
            } else {
                imageGroup.setHidden(true)
            }
            
            if let information = meal.zusatzStoffe {
                informationTable.setNumberOfRows(information.count, withRowType: "InformationRow")
                for index in 0..<informationTable.numberOfRows {
                    guard let controller = informationTable.rowController(at: index) as? InformationRowController else { continue }
                    controller.information = information[index]
                }
            } else {
                informationGroup.setHidden(true)
            }
            
            if let inhaltsStoffe = meal.inhaltsStoffe {
                stoffTable.setNumberOfRows(inhaltsStoffe.count, withRowType: "StoffRow")
                for index in 0..<stoffTable.numberOfRows {
                    guard let controller = stoffTable.rowController(at: index) as? StoffRowController else { continue }
                    controller.stoff = inhaltsStoffe[index]
                }
            } else {
                stoffTable.setNumberOfRows(1, withRowType: "StoffRow")
                guard let controller = stoffTable.rowController(at: 0) as? StoffRowController else { return }
                controller.stoff = Stoff(id: 0, title: "Keine Inhaltsstoffe vorhanden")
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
