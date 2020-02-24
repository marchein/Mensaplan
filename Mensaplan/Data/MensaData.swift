//
//  MensaData.swift
//  Mensaplan
//
//  Created by Marc Hein on 18.02.20.
//  Copyright © 2020 Marc Hein. All rights reserved.
//

import UIKit
import SwiftyXMLParser

class MensaData {
    var showSideDish = false
    var db = MensaDatabase()
    var JSONData: Mensaplan?
    var tempMensaData: MensaplanDay?
    var navigationController: UINavigationController?
    var mainVC: MainTableViewController?
    
    init(mainVC: MainTableViewController) {
        self.mainVC = mainVC
        self.navigationController = mainVC.parent as? UINavigationController
        if MensaplanApp.sharedDefaults.bool(forKey: LocalKeys.refreshOnStart) {
            loadXML()
        }
    }
    
    func loadXML() {
        if let mensaAPI = URL(string: MensaplanApp.API) {
            let dispatchQueue = DispatchQueue(label: "xmlThread", qos: .background)
            dispatchQueue.async {
                URLSession.shared.dataTask(with: mensaAPI, completionHandler: {(data, response, error) -> Void in
                    if let _ = error, let mainVC = self.mainVC {
                        print("MensaData.swift - loadXML() - error - no network connection")
                        DispatchQueue.main.async {
                            self.navigationController?.view.hideToastActivity()
                            self.navigationController?.view.makeToast("Fehler beim Laden der Daten.\nVersuche es bitte später erneut.")
                            mainVC.refreshControl?.endRefreshing()
                        }
                    } else {
                        if let response = response as? HTTPURLResponse, let data = data  {
                            print("MensaData.swift - loadXML() - statusCode: \(response.statusCode)")
                            let xml = XML.parse(data)
                            print("MensaData.swift - loadXML() - Successfully load xml")
                            self.processXML(with: xml)
                        }
                    }
                }).resume()
            }
        } else {
            fatalError("Provided invalid mensaAPI value")
        }
    }
    
    func processXML(with data: XML.Accessor) {
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
            return
        }
        
        MensaplanApp.sharedDefaults.set(data, forKey: LocalKeys.jsonData)
        print("MensaData.swift - processXML() - Successfully load JSON")
        loadJSONintoUI(data: data, local: false)
        
        MensaplanApp.sharedDefaults.set(Date.getCurrentDate(), forKey: LocalKeys.lastUpdate)
    }
    
    
    func loadJSONintoUI(data: Data, local: Bool) {
        do {
            let mensaData = try JSONDecoder().decode(Mensaplan.self, from: data)
            
            JSONData = mensaData
            DispatchQueue.main.async {
                print("MensaData.swift - loadJSONintoUI() - Successfully used \(local ? "local" : "remote") JSON in UI")
                if let mainVC = self.mainVC {
                    mainVC.showEmptyView()
                    self.navigationController?.view.hideToastActivity()
                    mainVC.refreshControl?.endRefreshing()
                    mainVC.tableView.reloadData()
                }
            }
        } catch {
            print(error)
        }
    }
}
