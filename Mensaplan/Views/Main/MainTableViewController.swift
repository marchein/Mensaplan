//
//  MainTableViewController.swift
//  Mensaplan
//
//  Created by Marc Hein on 18.10.19.
//  Copyright © 2019 Marc Hein. All rights reserved.
//

import UIKit
import SwiftyXMLParser

class MainTableViewController: UITableViewController {
    
    let API = "https://www.studiwerk.de/export/speiseplan.xml"
    let NOODLE_COUNTER = "CASA BLANCA"
    let MAIN_DISH_MINIMAL_PRICE: Double = 1.15
    var JSONData: Mensaplan?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        setupApp()
        if UserDefaults.standard.bool(forKey: LocalKeys.refreshOnStart) {
            loadXML()
        } else {
            print("load local copy")
            if let localCopyOfData = UserDefaults.standard.data(forKey: LocalKeys.jsonData) {
                getJSON(data: localCopyOfData)
            }
        }
    }
    
    func setupApp() {
        let isSetup  = UserDefaults.standard.bool(forKey: LocalKeys.isSetup)
        if !isSetup {
            UserDefaults.standard.set(true, forKey: LocalKeys.refreshOnStart)
            UserDefaults.standard.set("standort-1", forKey: LocalKeys.selectedMensa)
            UserDefaults.standard.set("student", forKey: LocalKeys.selectedPrice)
            UserDefaults.standard.set(true, forKey: LocalKeys.isSetup)
            print("INITIAL SETUP DONE")
        }
    }
    
    func loadXML() {
    if let mensaAPI = URL(string: API) {
        let dispatchQueue = DispatchQueue(label: "menuThread", qos: .background)
            dispatchQueue.async {
                URLSession.shared.dataTask(with: mensaAPI, completionHandler: {(data, response, error) -> Void in
                    if let error = error {
                        print("error: \(error)")
                    } else {
                        if let response = response as? HTTPURLResponse {
                            print("statusCode: \(response.statusCode)")
                        }
                        if let data = data, let xml = try? XML.parse(data) {
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
                    if let counterClosed = location["geschlossen"].text, counterClosed == "1" {
                        continue
                    }
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
                            if counterPlan["label"] as! String == NOODLE_COUNTER || mealPriceStudent >= MAIN_DISH_MINIMAL_PRICE {
                                var mealResult = [String: Any]()
                                mealResult["title"] = meal["titel"].text;
                                mealResult["priceStudent"] = mealPriceStudent;
                                mealResult["priceWorker"] = mealPriceWorker;
                                mealResult["pricePublic"] = mealPricePublic;
             
                                /*
                                 let data = meal.querySelector("hauptkomponente data");
                                 if (data) {
                                     let image = data.getAttribute("bild-url");
                                     if (image) {
                                         mealResult.image = STUDIWERK_URL + image;
                                     }
                                 }
                                 */
                                
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
                    locations.append(locationData)
                }

            }
            
            //if (dayPlanCounters.count > 0) {
                var locationResult: [String: Any] = [:]
                locationResult["location"] = locations
                plans.append(locationResult)
                print(plans.count)
           // }
            result["plan"] = plans
        }
        
        /*
         result.sort((dateResult1, dateResult2) => {
             return dateResult1.date - dateResult2.date;
         });
         */
        
        
        guard let data = try? JSONSerialization.data(withJSONObject: result, options: []) else {
            return
        }
        
        UserDefaults.standard.set(data, forKey: LocalKeys.jsonData)
        getJSON(data: data)
        
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "dd.MM.yyyy - HH:mm"
        let now = dateformatter.string(from: Date())
        UserDefaults.standard.set(now, forKey: LocalKeys.lastUpdate)
    }
    
    func getJSON(data: Data) {
        do {
            let mensaData = try JSONDecoder().decode(Mensaplan.self, from: data) 
            JSONData = mensaData
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        } catch {
            print("Error: Couldn't decode data into Mensaplan")
            print(error)
            // prints "No value associated with key title (\"title\")."
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detailSegue" {
            if let indexPath = self.tableView.indexPathForSelectedRow, let mensaData = JSONData {
                let selectedDay = mensaData.days[indexPath.row]
                print(selectedDay)
                let selectedLocation = UserDefaults.standard.string(forKey: LocalKeys.selectedMensa)!
                for location in selectedDay.location {
                    print(location)
                    if location.title == selectedLocation {
                        let vc = segue.destination as! DetailTableViewController
                        vc.mensaPlanDay = location.data
                        return
                    }
                }

            } else {
                print("Oops, no row has been selected")
            }
           
        }
    }
    
    
    @IBAction func refreshAction(_ sender: Any) {
        loadXML()
    }
    
    @IBAction func unwindFromSegue(segue: UIStoryboardSegue) {
        //refreshAction(self)
    }
}
