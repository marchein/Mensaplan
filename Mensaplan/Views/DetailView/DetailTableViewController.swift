//
//  DetailTableViewController.swift
//  Mensaplan
//
//  Created by Marc Hein on 20.10.19.
//  Copyright © 2019 Marc Hein. All rights reserved.
//

import UIKit
import HeinHelpers

class DetailTableViewController: UITableViewController {
    var mensaPlanDay: MensaplanDay?

    //MARK:- Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        if let mensaPlanDay = mensaPlanDay {
            self.title = HeinHelpers.getDayName(by: mensaPlanDay.getDateValue())

            if mensaPlanDay.isToday() {
                setupShortcutIntent(activityType: Shortcuts.showToday)
            } else if mensaPlanDay.isTomorrow() {
                setupShortcutIntent(activityType: Shortcuts.showTomorrow)
            }
        }
        #if targetEnvironment(macCatalyst)
            self.navigationController?.navigationBar.isHidden = true
        #endif
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if mensaPlanDay == nil, let splitVC = splitViewController, let splitNavVC = splitVC.viewControllers[1] as? UINavigationController {
            splitNavVC.performSegue(withIdentifier: MensaplanSegue.emptyDetail, sender: self)
        }
    }

    //MARK:- Segues
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
    
    //MARK:- Shortcuts
    func setupShortcutIntent(activityType: String) {
        let activity = NSUserActivity(activityType: activityType)
        activity.title = "Mensaplan für \(activityType == Shortcuts.showTomorrow ? "heute" : "morgen") anzeigen"
        activity.userInfo = ["speech" : "show plan for \(activityType == Shortcuts.showTomorrow ? "today" : "tomorrow")"]
        activity.isEligibleForSearch = true
        activity.isEligibleForPrediction = true
        activity.persistentIdentifier = NSUserActivityPersistentIdentifier(activityType)
        view.userActivity = activity
        activity.becomeCurrent()
    }
}
