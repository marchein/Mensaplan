//
//  MainTableViewController.swift
//  Mensaplan
//
//  Created by Marc Hein on 18.10.19.
//  Copyright © 2019 Marc Hein. All rights reserved.
//

import UIKit
import SwiftyXMLParser
import Toast_Swift

class MainTableViewController: UITableViewController {
    var JSONData: Mensaplan?
    var tempMensaData: MensaplanDay?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        setupApp()
        if MensaplanApp.sharedDefaults.bool(forKey: LocalKeys.refreshOnStart) {
            loadXML()
        }
        self.refreshControl?.addTarget(self, action: #selector(refresh), for: UIControl.Event.valueChanged)
    }
    
    func setupApp() {
        let isSetup  = MensaplanApp.sharedDefaults.bool(forKey: LocalKeys.isSetup)
        if !isSetup {
            MensaplanApp.sharedDefaults.set(true, forKey: LocalKeys.refreshOnStart)
            MensaplanApp.sharedDefaults.set("standort-1", forKey: LocalKeys.selectedMensa)
            MensaplanApp.sharedDefaults.set("student", forKey: LocalKeys.selectedPrice)
            MensaplanApp.sharedDefaults.set(true, forKey: LocalKeys.isSetup)
            print("INITIAL SETUP DONE")
        } else {
            print("load local copy")
            if let localCopyOfData = MensaplanApp.sharedDefaults.data(forKey: LocalKeys.jsonData) {
                getJSON(data: localCopyOfData)
            }
        }
    }

    public func showDay(dayValue: DayValue) {
        guard let mensaData = JSONData else {
            return
        }
        var dayIndex = -1
        for days in mensaData.plan {
            dayIndex += 1
            if dayValue == DayValue.TODAY {
                if days.day[0].isToday() {
                    break
                }
            } else if dayValue == DayValue.TOMORROW {
                if days.day[0].isTomorrow() {
                    break
                }
            }
        }
        let selectedDay = mensaData.plan[dayIndex]
        let selectedLocation = MensaplanApp.sharedDefaults.string(forKey: LocalKeys.selectedMensa)!
        for location in selectedDay.day {
            if location.title == selectedLocation {
                tempMensaData = location.data
                let navVC = self.parent as! UINavigationController
                navVC.popToRootViewController(animated: true)
                performSegue(withIdentifier: "manualDetailSegue", sender: self)
                return
            }
        }
   }

    func loadXML() {
        if let mensaAPI = URL(string: MensaplanApp.API) {
        self.navigationController?.view.makeToastActivity(.center)
        let dispatchQueue = DispatchQueue(label: "xmlThread", qos: .background)
            dispatchQueue.async {
                URLSession.shared.dataTask(with: mensaAPI, completionHandler: {(data, response, error) -> Void in
                    if let error = error {
                        print("try to load local copy")
                        if let localCopyOfData = MensaplanApp.sharedDefaults.data(forKey: LocalKeys.jsonData) {
                            self.getJSON(data: localCopyOfData)
                            DispatchQueue.main.async {
                                self.navigationController?.view.hideToastActivity()
                                self.navigationController?.view.makeToast("Fehler beim Aktualisieren der Daten.\nVersuche es bitte später erneut.")
                            }
                        } else {
                            DispatchQueue.main.async {
                                self.navigationController?.view.hideToastActivity()
                                self.navigationController?.view.makeToast("Fehler beim Laden der Daten.\nVersuche es bitte später erneut.")
                            }
                        }
                        print("error: \(error)")
                    } else {
                        if let response = response as? HTTPURLResponse, let data = data  {
                            print("statusCode: \(response.statusCode)")
                            let xml = XML.parse(data)
                            print("Successfully load xml")
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
                            if counterPlan["label"] as! String == MensaplanApp.NOODLE_COUNTER || mealPriceStudent >= MensaplanApp.MAIN_DISH_MINIMAL_PRICE {
                                var mealResult = [String: Any]()
                                mealResult["title"] = meal["titel"].text;
                                mealResult["priceStudent"] = mealPriceStudent;
                                mealResult["priceWorker"] = mealPriceWorker;
                                mealResult["pricePublic"] = mealPricePublic;
             
                                let mealMainPart = meal["hauptkomponente", "mahlzeitkomponenten-list", "mahlzeitkomponenten-item", "data"]
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
                    locations.append(locationData)
                }

            }
            
            var locationResult: [String: Any] = [:]
            locationResult["location"] = locations
            plans.append(locationResult)
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
        
        MensaplanApp.sharedDefaults.set(data, forKey: LocalKeys.jsonData)
        print("Successfully load JSON")
        getJSON(data: data)
        
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "dd.MM.yyyy - HH:mm"
        let now = dateformatter.string(from: Date())
        MensaplanApp.sharedDefaults.set(now, forKey: LocalKeys.lastUpdate)
    }
    
    func getJSON(data: Data) {
        do {
            let mensaData = try JSONDecoder().decode(Mensaplan.self, from: data) 
            JSONData = mensaData
            DispatchQueue.main.async {
                print("Successfully used JSON in UI")
                self.navigationController?.view.hideToastActivity()
                self.tableView.reloadData()
            }
        } catch {
            print(error)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detailSegue" {
            if let indexPath = self.tableView.indexPathForSelectedRow, let mensaData = JSONData {
                let selectedDay = mensaData.plan[indexPath.row]
                let selectedLocation = MensaplanApp.sharedDefaults.string(forKey: LocalKeys.selectedMensa)!
                for location in selectedDay.day {
                    if location.title == selectedLocation {
                        let vc = segue.destination as! DetailTableViewController
                        vc.mensaPlanDay = location.data
                        return
                    }
                }
            } else {
                print("Oops, no row has been selected")
            }
        } else if segue.identifier == "manualDetailSegue" {
            let vc = segue.destination as! DetailTableViewController
            vc.mensaPlanDay = tempMensaData
        }
    }
    
    
    @IBAction func refreshAction(_ sender: Any) {
        loadXML()
    }
    
    @IBAction func unwindFromSegue(segue: UIStoryboardSegue) {
        self.tableView.reloadData()
    }
    
    @objc func refresh(sender: Any) {
        // Updating your data here...
        refreshAction(sender)

        self.tableView.reloadData()
        self.refreshControl?.endRefreshing()
    }
}
