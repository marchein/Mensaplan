//
//  MensacardTableViewController.swift
//  Mensaplan
//
//  Created by Marc Hein on 05.05.21.
//  Copyright © 2021 Marc Hein. All rights reserved.
//

import UIKit
import CoreNFC
import HeinHelpers


class MensacardTableViewController: UITableViewController {
    let mensaDB = MensaDatabase()
    
    var mainVC: MainTableViewController {
        get {
            guard let splitVC = UIApplication.shared.windows.first!.rootViewController as? UISplitViewController,
                  let tabVC = splitVC.children.first as? UITabBarController,
                  let navVC = tabVC.children.first as? UINavigationController,
                  let mainVC = navVC.children.first as? MainTableViewController else {
                fatalError("MainVC is nil!")
            }
            return mainVC
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        for entry in mensaDB.getEntries().reversed() {
            print("\(entry) ID: \(entry.id) Date: \(entry.date) Balance: \(entry.balance) Last Transaction: \(entry.lastTransaction) CardID: \(entry.cardID)")
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row != 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cardCell", for: indexPath)
            let data: [HistoryItem] = mensaDB.getEntries()
            if data.count == 0 {
                cell.textLabel?.isEnabled = false
                cell.detailTextLabel?.isEnabled = false
                cell.textLabel?.textColor = .secondaryLabel
            } else {
                cell.textLabel?.textColor = .label
            }
            
            if indexPath.row == 0 {
                cell.textLabel?.text = "Guthaben"
                cell.detailTextLabel?.text = data.count > 0 ? String(format: "%.2f €", data[0].balance) : "0,00 €"
            } else if indexPath.row == 1 {
                cell.textLabel?.text = "Letzte Transaktion"
                cell.detailTextLabel?.text =  data.count > 0 ? String(format: "%.2f €", data[0].lastTransaction) : "0,00 €"
            }
            return cell
        } else {
            return tableView.dequeueReusableCell(withIdentifier: "scanCell", for: indexPath)
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if MensaplanApp.canScan {
            return "Guthaben"
        }
        return nil
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == 0 {
            if let lastUpdate = MensaplanApp.sharedDefaults.string(forKey: LocalKeys.lastUpdate), let dateObj = mainVC.getDate(from: lastUpdate)  {
                #if targetEnvironment(macCatalyst)
                return "Letzte Aktualisierung: \(Date.getCurrentDate(short: true, date: dateObj)) Uhr"
                #else
                return "Letzte Aktualisierung: \(lastUpdate) Uhr"
                #endif
            }
            return "Keine Aktualisierung vorgenommen"
        } else if MensaplanApp.canScan, section == 1 {
            let data: [HistoryItem] = mensaDB.getEntries()
            if data.count > 0 {
                return "Einlesedatum: \(data[0].date) Uhr"
            }
            return "Guthaben wurde noch nicht eingelesen"
        }
        return nil
    }
}
