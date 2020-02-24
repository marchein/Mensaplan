//
//  MainTableViewController.swift
//  Mensaplan
//
//  Created by Marc Hein on 18.10.19.
//  Copyright © 2019 Marc Hein. All rights reserved.
//

import UIKit
import Toast_Swift
import CoreNFC

class MainTableViewController: UITableViewController {
    var mensaData: MensaData?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mensaData = MensaData(mainVC: self)
        setupApp()
        self.refreshControl?.addTarget(self, action: #selector(refreshAction), for: UIControl.Event.valueChanged)
    }
    
    func setupApp() {
        let isSetup  = MensaplanApp.sharedDefaults.bool(forKey: LocalKeys.isSetup)
        
        if !isSetup {
            MensaplanApp.sharedDefaults.set(true, forKey: LocalKeys.refreshOnStart)
            MensaplanApp.sharedDefaults.set(false, forKey: LocalKeys.showSideDish)
            MensaplanApp.sharedDefaults.set("standort-1", forKey: LocalKeys.selectedMensa)
            MensaplanApp.sharedDefaults.set("student", forKey: LocalKeys.selectedPrice)
            MensaplanApp.sharedDefaults.set(true, forKey: LocalKeys.isSetup)
            print("MainTableViewController.swift - setupApp() -INITIAL SETUP DONE")
        } else {
            print("MainTableViewController.swift - setupApp() - load local copy")
            if let localCopyOfData = MensaplanApp.sharedDefaults.data(forKey: LocalKeys.jsonData), let mensaData = self.mensaData {
                mensaData.loadJSONintoUI(data: localCopyOfData,local: true)
            }
        }
        
        if MensaplanApp.demo, let mensaData = self.mensaData {
            mensaData.db.insertRecord(
                balance: 19.56,
                lastTransaction: 2.85,
                date: Date.getCurrentDate(),
                cardID: "1234567890"
            )
        }
    }
    
    public func showDay(dayValue: DayValue) {
        guard let mensaData = self.mensaData, let mensaDataJSON = mensaData.JSONData else {
            return
        }
        var dayIndex = -1
        for days in mensaDataJSON.plan {
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
        let selectedDay = mensaDataJSON.plan[dayIndex]
        let selectedLocation = MensaplanApp.sharedDefaults.string(forKey: LocalKeys.selectedMensa)!
        for location in selectedDay.day {
            if location.title == selectedLocation {
                if location.closed {
                    let when = dayValue == DayValue.TODAY ? " heute " : dayValue == DayValue.TOMORROW ? " morgen ": " "
                    showMessage(title: "Mensa\(when)geschlossen", message: location.closedReason ?? "Bitte die Aushänge beachten", on: self)
                } else {
                    if dayValue == .TODAY && !selectedDay.day[0].isToday() || dayValue == .TOMORROW && !selectedDay.day[0].isTomorrow() {
                        showMessage(title: "Geschlossen", message: "Heute werde keine Gerichte in der Mensa angeboten", on: self)
                    } else {
                        mensaData.tempMensaData = location.data
                        let navVC = self.parent as! UINavigationController
                        navVC.popToRootViewController(animated: true)
                        performSegue(withIdentifier: MensaplanSegue.manualShowDetail, sender: self)
                    }
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == MensaplanSegue.showDetail {
            if let indexPath = self.tableView.indexPathForSelectedRow, let mensaData = self.mensaData, let mensaDataJSON = mensaData.JSONData {
                let selectedDay = mensaDataJSON.plan[indexPath.row]
                let selectedLocation = MensaplanApp.sharedDefaults.string(forKey: LocalKeys.selectedMensa)!
                for location in selectedDay.day {
                    if location.title == selectedLocation {
                        let vc = (segue.destination as! UINavigationController).topViewController as! DetailTableViewController
                        vc.mensaPlanDay = location.data
                        return
                    }
                }
            } else {
                print("Oops, no row has been selected")
            }
        } else if segue.identifier == MensaplanSegue.manualShowDetail {
            if let destination = segue.destination as? UINavigationController,
                let detailTableVC = destination.topViewController as? DetailTableViewController,
                let mensaData = self.mensaData {
                detailTableVC.mensaPlanDay = mensaData.tempMensaData
            }
        }
    }
    
    @IBAction @objc func refreshAction(_ sender: Any) {
        if let _ = sender as? UIRefreshControl {
            // refresh from refresh control
        } else {
            self.navigationController?.view.makeToastActivity(.center)
        }
        if let mensaData = self.mensaData {
            mensaData.loadXML()
        }
    }
    
    @IBAction func unwindFromSegue(segue: UIStoryboardSegue) {
        if let mensaData = self.mensaData, mensaData.showSideDish != MensaplanApp.sharedDefaults.bool(forKey: LocalKeys.showSideDish) {
            refreshAction(self)
        } else {
            self.tableView.reloadData()
        }
        //decide if changes have been made
        showEmptyView()
    }
    
    func showEmptyView() {
        if let splitVC = self.splitViewController, splitVC.viewControllers.count > 1 ,let splitNavVC = splitVC.viewControllers[1] as? UINavigationController {
            splitNavVC.performSegue(withIdentifier: MensaplanSegue.emptyDetail, sender: self)
        }
    }
}
