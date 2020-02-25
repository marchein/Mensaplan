//
//  MainInterfaceController.swift
//  Watchapp Extension
//
//  Created by Marc Hein on 24.02.20.
//  Copyright © 2020 Marc Hein. All rights reserved.
//

import WatchKit
import WatchSync


class MainInterfaceController: WKInterfaceController {
    let COUNTER_ROW = "CounterRow"
    let MEAL_ROW = "MealRow"
    let defaults = UserDefaults.standard
    
    var subscriptionToken: SubscriptionToken?
    var mensaData: Mensaplan?
    var lastUpdate: String?
    var selectedMensa: String?
    var selectedPrice: String?
    var jsonData: Data?
    var meals: [Meal?] = []
    
    
    
    
    @IBOutlet weak var locationLabel: WKInterfaceLabel!
    @IBOutlet weak var introLabel: WKInterfaceLabel!
    @IBOutlet weak var mealsTable: WKInterfaceTable!
    
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        subscriptionToken = WatchSync.shared.subscribeToMessages(ofType: WatchMessage.self) {  newWatchMessage in
            self.processWatchMessage(message: newWatchMessage)
        }
        
        setup()
    }
    
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        let meal = meals[rowIndex]
        presentController(withName: "Meal", context: meal)
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    func processWatchMessage(message: WatchMessage) {
        if let lastUpdate = message.lastUpdate {
            defaults.set(lastUpdate, forKey: LocalKeys.lastUpdate)
        }
        
        if let selectedMensa = message.selectedMensa {
            defaults.set(selectedMensa, forKey: LocalKeys.selectedMensa)
        }
        
        if let selectedPrice = message.selectedPrice {
            defaults.set(selectedPrice, forKey: LocalKeys.selectedPrice)
        }
        
        if let jsonData = message.jsonData {
            defaults.set(jsonData, forKey: LocalKeys.jsonData)
        }
        
        setup()
    }
    
    func setup() {
        DispatchQueue.main.async {
            self.introLabel.setHidden(false)
            self.mealsTable.setHidden(true)
        }
        
        self.lastUpdate = defaults.string(forKey: LocalKeys.lastUpdate)
        self.selectedMensa = defaults.string(forKey: LocalKeys.selectedMensa)
        self.selectedPrice = defaults.string(forKey: LocalKeys.selectedPrice)
        self.jsonData = defaults.data(forKey: LocalKeys.jsonData)
        
        if self.jsonData == nil {
            DispatchQueue.main.async {
                self.locationLabel.setText("Öffne \"Mensaplan\" auf Deinem iPhone")
                self.introLabel.setText("Damit der Mensaplan angezeigt werden kann, muss sich deine Apple Watch mit deinem iPhone verbinden")
            }
        }
        
        dismiss()
        
        parseJSONToObject(data: self.jsonData)
    }
    
    func parseJSONToObject(data: Data?) {
        if let rawMensaData = data {
            do {
                self.mensaData = try JSONDecoder().decode(Mensaplan.self, from: rawMensaData)
                if let mensaData = mensaData {
                    processMensaData(data: mensaData)
                }
            } catch {
                print(error)
            }
        }
    }
    
    func processMensaData(data: Mensaplan) {
        let locations = data.plan
        for location in locations {
            for locationDay in location.day {
                if Calendar.autoupdatingCurrent.isDateInToday(locationDay.getDateValue()), locationDay.title == self.selectedMensa! {
                    DispatchQueue.main.async {
                        let index = MensaplanApp.standorteKeys.firstIndex(of: locationDay.title)!
                        self.locationLabel.setText(MensaplanApp.standorteValues[index])
                        if locationDay.closed {
                            self.introLabel.setText(locationDay.closedReason)
                            self.introLabel.setHidden(false)
                        }
                        self.setupTable(counters: locationDay.data.counters)
                    }
                }
            }
        }
    }
    
    func setupTable(counters: [Counter]) {
        meals = []
        var _numberOfMealsInCounter: [Int: Int] = [:]
        
        for index in 0..<counters.count {
            _numberOfMealsInCounter[index] = counters[index].meals.count
        }
        
        let numberOfMealsInCounter = _numberOfMealsInCounter.sorted(by: {$0.0 < $1.0})
        
        let types = getRowTypes(numberOfMealsInCounter: numberOfMealsInCounter)
        mealsTable.setRowTypes(types)
        
        var counterIndex = 0
        var mealIndex = 0
        for index in 0..<mealsTable.numberOfRows {
            if types[index] == COUNTER_ROW {
                guard let counterController = mealsTable.rowController(at: index) as? CounterRowController else { continue }
                meals.append(nil)
                counterController.counterName = counters[counterIndex].label
                if counterIndex + 1 < counters.count {
                    mealIndex = 0
                }
            } else if types[index] == MEAL_ROW {
                guard let controller = mealsTable.rowController(at: index) as? MealRowController else { continue }
                let currentMeal = counters[counterIndex].meals[mealIndex]
                controller.meal = currentMeal
                meals.append(currentMeal)
                if mealIndex + 1 < numberOfMealsInCounter[counterIndex].value {
                    mealIndex += 1
                } else {
                    counterIndex += 1
                    mealIndex = 0
                }
            }
        }
        if mealsTable.numberOfRows > 0 {
            mealsTable.setHidden(false)
            introLabel.setHidden(true)
        }
    }
    
    
    
    func getRowTypes(numberOfMealsInCounter: [(key: Int, value: Int)]) -> [String] {
        var types: [String] = []
        for (_, meals) in numberOfMealsInCounter {
            types.append(COUNTER_ROW)
            for _ in 0..<meals {
                types.append(MEAL_ROW)
            }
        }
        return types
    }
    
}
