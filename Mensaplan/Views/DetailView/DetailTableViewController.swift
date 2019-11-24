//
//  DetailTableViewController.swift
//  Mensaplan
//
//  Created by Marc Hein on 20.10.19.
//  Copyright © 2019 Marc Hein. All rights reserved.
//

import UIKit

class DetailTableViewController: UITableViewController {
    
    var mensaPlanDay: MensaplanDay?

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let mensaPlanDay = mensaPlanDay else {
            return
        }
        
        title = getDayName(by: mensaPlanDay.getDateValue())

        if mensaPlanDay.isToday() {
            setupTodayIntent()
        } else if mensaPlanDay.isTomorrow() {
            setupTomorrowIntent()
        }
        
        /*
        var possibleZusatz = [Any]()

        
        for couter in mensaPlanDay.counters {
            for meal in couter.meals {
                if let zusatz = meal.zusatzStoffe {
                    for zs in zusatz {
                        var item = [String: String]()
                        let id: String = "\(zs.id)"
                        let title = zs.title
                        item["id"] = id
                        item["title"] = title
                        if !containsValue(array: possibleZusatz, id: id) {
                            possibleZusatz.append(item)
                        }
                        
                    }
                }
                
            }
        }
        print("possibleZusatz: \(possibleZusatz)")
        */
    }
    
     /*
     func containsValue(array: [Any], id: String) -> Bool {
        for item in array {
            let i = item as! [String: String]
            if i["id"] == id {
                return true
            }
        }
        return false
    }
    */
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if mensaPlanDay == nil, let splitVC = splitViewController, let splitNavVC = splitVC.viewControllers[1] as? UINavigationController {
            splitNavVC.performSegue(withIdentifier: MensaplanSegue.emptyDetail, sender: self)
        }
    }
    
    func setupTodayIntent() {
        let activity = NSUserActivity(activityType: Shortcuts.showToday) // 1
        activity.title = "Mensaplan für heute anzeigen" // 2
        activity.userInfo = ["speech" : "show plan for today"] // 3
        activity.isEligibleForSearch = true // 4
        if #available(iOS 12.0, *) {
            activity.isEligibleForPrediction = true
            activity.persistentIdentifier = NSUserActivityPersistentIdentifier(Shortcuts.showToday)
        }
        view.userActivity = activity // 7
        activity.becomeCurrent() // 8
    }
    
    func setupTomorrowIntent() {
        let activity = NSUserActivity(activityType: Shortcuts.showTomorrow) // 1
        activity.title = "Mensaplan für morgen anzeigen" // 2
        activity.userInfo = ["speech" : "show plan for tomorrow"] // 3
        activity.isEligibleForSearch = true // 4
        if #available(iOS 12.0, *) {
            activity.isEligibleForPrediction = true
            activity.persistentIdentifier = NSUserActivityPersistentIdentifier(Shortcuts.showTomorrow)
        }
        view.userActivity = activity // 7
        activity.becomeCurrent() // 8
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showMealSegue" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let meal = mensaPlanDay!.counters[indexPath.section].meals[indexPath.row]
                let vc = segue.destination as! MealTableViewController
                vc.meal = meal
            } else {
                print("Oops, no row has been selected")
            }
        }
    }
}
