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
import WatchSync
import HeinHelpers

class MainTableViewController: UITableViewController {
    @IBOutlet weak var navBar: UINavigationItem!
    @IBOutlet weak var settingsButton: UIBarButtonItem!
    
    var mensaContainer: MensaContainer?
    var subscriptionToken: SubscriptionToken?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mensaContainer = MensaContainer(mainVC: self)
        self.refreshControl?.addTarget(self, action: #selector(refreshAction), for: UIControl.Event.valueChanged)
        
        self.setupApp()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.buildMacToolbar()
    }
    
    func setupApp() {
        let isSetup  = MensaplanApp.sharedDefaults.bool(forKey: LocalKeys.isSetup)
        
        if !isSetup {
            MensaplanApp.sharedDefaults.set(true, forKey: LocalKeys.refreshOnStart)
            MensaplanApp.sharedDefaults.set(false, forKey: LocalKeys.showSideDish)
            MensaplanApp.sharedDefaults.set("standort-1", forKey: LocalKeys.selectedMensa)
            MensaplanApp.sharedDefaults.set("student", forKey: LocalKeys.selectedPrice)
            MensaplanApp.sharedDefaults.set(true, forKey: LocalKeys.isSetup)
            print("MainTableViewController.swift - setupApp() - INITIAL SETUP DONE")
            refreshAction(self)
        } else {
            print("MainTableViewController.swift - setupApp() - load local copy")
            if let localCopyOfMensaplanData = MensaplanApp.sharedDefaults.data(forKey: LocalKeys.mensaplanJSONData), let mensaContainer = self.mensaContainer {
                mensaContainer.loadJSONintoUI(mensaPlanData: localCopyOfMensaplanData, local: true)
            }
        }
        
        if #available(iOS 13.0,*)  {
            self.settingsButton.image = UIImage(systemName: "gear")
        }
        subscriptionToken = WatchSync.shared.subscribeToMessages(ofType: WatchMessage.self) { watchMessage in
            print(String(describing: watchMessage.lastUpdate), String(describing: watchMessage.selectedMensa), String(describing: watchMessage.selectedPrice), String(describing: watchMessage.jsonData))
        }
        
        if MensaplanApp.demo, let mensaData = self.mensaContainer {
            mensaData.db.insertRecord(
                balance: 19.56,
                lastTransaction: 2.85,
                date: Date.getCurrentDate(),
                cardID: "1234567890"
            )
        }
        
        #if targetEnvironment(macCatalyst)
        self.navigationController?.navigationBar.isHidden = true
        #endif
    }
    
    @objc func openSettings() {
        self.performSegue(withIdentifier: MensaplanSegue.showSettings, sender: self)
    }
    
    public func showDay(dayValue: DayValue) {
        guard let mensaContainer = self.mensaContainer, let mensaData = mensaContainer.mensaData else {
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
                if location.closed {
                    let when = dayValue == .TODAY ? " heute " : dayValue == .TOMORROW ? " morgen ": " "
                    HeinHelpers.showMessage(title: "Mensa\(when)geschlossen", message: location.closedReason ?? "Bitte die Aushänge beachten", on: self)
                } else {
                    let when = dayValue == .TODAY ? "Heute" : dayValue == .TOMORROW ? "Morgen": " "
                    if dayValue == .TODAY && !selectedDay.day[0].isToday() || dayValue == .TOMORROW && !selectedDay.day[0].isTomorrow() {
                        HeinHelpers.showMessage(title: "Geschlossen", message: "\(when) werden keine Gerichte in der Mensa angeboten", on: self)
                    } else {
                        mensaContainer.tempMensaData = location.data
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
            if let indexPath = self.tableView.indexPathForSelectedRow, let mensaContainer = self.mensaContainer, let mensaData = mensaContainer.mensaData {
                let selectedDay = mensaData.plan[indexPath.row]
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
                let mensaData = self.mensaContainer {
                detailTableVC.mensaPlanDay = mensaData.tempMensaData
            }
        }
    }
    
    @IBAction @objc func refreshAction(_ sender: Any) {
        if let _ = sender as? UIRefreshControl {
            // refresh from refresh control
        } else {
            DispatchQueue.main.async {
                self.navigationController?.view.makeToastActivity(.center)
            }
        }
        if let mensaContainer = self.mensaContainer {
            mensaContainer.loadMensaData()
        }
    }
    
    @IBAction func unwindFromSegue(segue: UIStoryboardSegue) {
        if let mensaContainer = self.mensaContainer, mensaContainer.mensaXML?.showSideDish != MensaplanApp.sharedDefaults.bool(forKey: LocalKeys.showSideDish) {
            refreshAction(self)
        } else {
            self.tableView.reloadData()
        }
        
        #if !targetEnvironment(macCatalyst)
        sendMessageToWatch()
        #endif
        //decide if changes have been made
        showEmptyView()
    }
    
    func showEmptyView() {
        if let splitVC = self.splitViewController, splitVC.viewControllers.count > 1 ,let splitNavVC = splitVC.viewControllers[1] as? UINavigationController {
            splitNavVC.performSegue(withIdentifier: MensaplanSegue.emptyDetail, sender: self)
        }
    }
    
    #if !targetEnvironment(macCatalyst)
    func sendMessageToWatch() {
        //print("Sending message to watch")
        let selectedPrice = MensaplanApp.sharedDefaults.string(forKey: LocalKeys.selectedPrice)
        let selectedMensa = MensaplanApp.sharedDefaults.string(forKey: LocalKeys.selectedMensa)
        let lastUpdate = MensaplanApp.sharedDefaults.string(forKey: LocalKeys.lastUpdate)
        let jsonData = MensaplanApp.sharedDefaults.data(forKey: LocalKeys.mensaplanJSONData)
        
        let newWatchMessage = WatchMessage(selectedPrice: selectedPrice, selectedMensa: selectedMensa, lastUpdate: lastUpdate, jsonData: jsonData)
        
        WatchSync.shared.sendMessage(newWatchMessage, completion: nil)
    }
    #endif
}
