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
    let MAIN_DISH_MINIMAL_PRICE: Float = 1.15
    var dataFromApi: Data?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        loadXML()
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
            var dayPlan = [String: Any]()
            var dayPlanCounters = [Any]()

            if let location = getLocation(xml: dates["content", "calendarday", "standort-liste"]) {
                if let counterClosed = location["geschlossen"].text, counterClosed == "1" {
                    continue
                }
                
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
                        var mealPrice: Float = 0
                        for price in prices {
                            if let priceId = price.attributes["id"], priceId == "price-1", let mealPriceString = price.attributes["data"] {
                                mealPrice = Float(mealPriceString)!
                            }
                        }
                        if counterPlan["label"] as! String == NOODLE_COUNTER || mealPrice >= MAIN_DISH_MINIMAL_PRICE {
                            var mealResult = [String: Any]()
                            mealResult["title"] = meal["titel"].text;
                            mealResult["price"] = mealPrice;
                            
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

            }
            
            if (dayPlanCounters.count > 0) {
                plans.append(dayPlan)
            }
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

        dataFromApi = data
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func getLocation(xml: XML.Accessor) -> XML.Accessor? {
        for location in xml["standort"] {
            if let locationValue = location.attributes["id"], locationValue == "standort-4" {
                return location
            }
        }
        return nil
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detailSegue" {
            if let indexPath = self.tableView.indexPathForSelectedRow, let dataFromApi = dataFromApi {
               guard let mensaData = try? JSONDecoder().decode(Mensaplan.self, from: dataFromApi) else {
                   print("Error: Couldn't decode data into Blog")
                    return
               }
                let vc = segue.destination as! DetailTableViewController
                vc.mensaPlanDay = mensaData.days[indexPath.row]
            } else {
                print("Oops, no row has been selected")
            }
           
        }
    }
}
