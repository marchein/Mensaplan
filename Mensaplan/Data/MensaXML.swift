//
//  MensaXML.swift
//  Mensaplan
//
//  Created by Marc Hein on 26.02.20.
//  Copyright © 2020 Marc Hein. All rights reserved.
//

import Foundation
import SwiftyXMLParser

class MensaXML {
    var showSideDish = false
    var apiURL: URL?
    var apiData: Data?
    
    init(url: URL?) {
        self.apiURL = url
    }
    
    func loadXML(onDone: @escaping (Data) -> Void) {
        if let apiURL = apiURL {
            let dispatchQueue = DispatchQueue(label: "xmlThread", qos: .background)
            dispatchQueue.async {
                URLSession.shared.dataTask(with: apiURL, completionHandler: {(data, response, error) -> Void in
                    if let error = error {
                        print(error.localizedDescription)
                    } else {
                        if let data = data  {
                            let xml = XML.parse(data)
                            if let data = self.processXML(with: xml) {
                                onDone(data)
                            }
                        }
                    }
                }).resume()
            }
        }
    }
    
    func processXML(with data: XML.Accessor) -> Data? {
        var result: [String: Any] = [:]
        var plans = [Any]()
        for dates in data["artikel-liste", "artikel"].makeIterator() {
            var locations = [Any]()
            
            for location in dates["content", "calendarday", "standort-liste"]["standort"] {
                if let locationValue = location.attributes["id"] {
                    var dayPlan = [String: Any]()
                    var dayPlanCounters = [Any]()
                    
                    dayPlan["date"] = Int(dates.attributes["date"]!)
                    dayPlan["counters"] = []
                    
                    let counters = location["theke-liste", "theke"]
                    for counter in counters {
                        var counterPlan = [String: Any]()
                        counterPlan["label"] = counter["label"].text!
                        
                        var counterMeals = [Any]()
                        
                        let meals = counter["mahlzeit-liste", "mahlzeit"].makeIterator()
                        for meal in meals {
                            let prices = meal["price"].makeIterator()
                            var mealPriceStudent: Double = 0
                            var mealPriceWorker: Double = 0
                            var mealPricePublic: Double = 0
                            for price in prices {
                                if let id = price.attributes["id"], let value = price.attributes["data"], let mealPrice = Double(value) {
                                    switch id {
                                    case "price-1":
                                        mealPriceStudent = mealPrice
                                        break
                                    case "price-2":
                                        mealPriceWorker = mealPrice
                                        break
                                    case "price-3":
                                        mealPricePublic = mealPrice
                                        break
                                    default:
                                        break
                                    }
                                }
                            }
                            showSideDish = MensaplanApp.sharedDefaults.bool(forKey: LocalKeys.showSideDish)
                            if showSideDish || counterPlan["label"] as! String == MensaplanApp.NOODLE_COUNTER || mealPriceStudent >= MensaplanApp.MAIN_DISH_MINIMAL_PRICE {
                                var mealResult = [String: Any]()
                                mealResult["title"] = meal["titel"].text;
                                mealResult["priceStudent"] = mealPriceStudent;
                                mealResult["priceWorker"] = mealPriceWorker;
                                mealResult["pricePublic"] = mealPricePublic;
                                
                                let mealMainPart = meal["hauptkomponente", "mahlzeitkomponenten-list", "mahlzeitkomponenten-item", "data"]
                                
                                let inhaltsstoffe = mealMainPart["inhaltsstoffe", "item"].makeIterator()
                                var inhaltsstoffeValues: [Any] = [Any]()
                                for item in inhaltsstoffe {
                                    var inhaltsstoffeData = [String: Any]()
                                    inhaltsstoffeData["id"] = Int(item.attributes["id"]!)!
                                    inhaltsstoffeData["title"] = item.text
                                    inhaltsstoffeValues.append(inhaltsstoffeData)
                                }
                                
                                mealResult["inhaltsstoffe"] = inhaltsstoffeValues.count > 0 ? inhaltsstoffeValues : nil
                                
                                let zusatzstoffe = mealMainPart["zusatzstoffe", "item"].makeIterator()
                                var zusatzstoffeValues: [Any] = [Any]()
                                for item in zusatzstoffe {
                                    var zusatzstoffeData = [String: Any]()
                                    zusatzstoffeData["id"] = Int(item.attributes["key"]!)!
                                    zusatzstoffeData["title"] = item.text
                                    zusatzstoffeValues.append(zusatzstoffeData)
                                }
                                
                                mealResult["zusatzstoffe"] = zusatzstoffeValues.count > 0 ? zusatzstoffeValues : nil
                                
                                let image = mealMainPart.attributes["bild-url"]
                                mealResult["image"] = image != nil ? "\(MensaplanApp.STUDIWERK_URL)\(image!)" : nil
                                
                                counterMeals.append(mealResult)
                            }
                        }
                        counterPlan["meals"] = counterMeals
                        
                        if counterMeals.count > 0 {
                            dayPlanCounters.append(counterPlan)
                        }
                        dayPlan["counters"] = dayPlanCounters
                    }
                    var locationData = [String: Any]()
                    
                    locationData["date"] = Int(dates.attributes["date"]!)
                    locationData["data"] = dayPlan
                    locationData["title"] = locationValue
                    locationData["closed"] = location["geschlossen"].text ?? "0" == "1"
                    locationData["closedReason"] = location["geschlossen_hinweis"].text
                    
                    locations.append(locationData)
                }
                
            }
            
            var locationResult: [String: Any] = [:]
            locationResult["location"] = locations
            plans.append(locationResult)
            result["plan"] = plans
        }
        
        guard let data = try? JSONSerialization.data(withJSONObject: result, options: []) else {
            return nil
        }
        return data
    }
}
