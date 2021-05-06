//
//  SettingsMensaLocationTableViewController.swift
//  Mensaplan
//
//  Created by Marc Hein on 05.08.20.
//  Copyright © 2020 Marc Hein. All rights reserved.
//

import UIKit
import HeinHelpers

class SettingsTabTableViewController: UITableViewController {
    
    var mainVC: MainTableViewController? {
        get {
            guard let splitVC = UIApplication.shared.windows.first!.rootViewController as? UISplitViewController,
                let navVC = splitVC.children.first as? UINavigationController,
                let mainVC = navVC.children.first as? MainTableViewController else {
                    return nil
            }
            return mainVC
        }
    }
    
    var selectedTab: String? {
        get {
            return MensaplanApp.sharedDefaults.string(forKey: LocalKeys.defaultTab)
        }
        
        set {
            MensaplanApp.sharedDefaults.set(newValue, forKey: LocalKeys.defaultTab)
            var indexPaths: [IndexPath] = []
            for i in 0..<self.tableView(self.tableView, numberOfRowsInSection: tableView.numberOfSections) {
                if i != selectedTabIndex {
                    let indexPath = IndexPath(row: i, section: 0)
                    indexPaths.append(indexPath)
                    let cell = self.tableView(self.tableView, cellForRowAt: indexPath)
                    cell.accessoryType = .none
                }
            }
            self.mainVC?.refreshAction(self)
            indexPaths.append(IndexPath(row: selectedTabIndex, section: 0))
            
            self.tableView.reloadRows(at: indexPaths, with: .automatic)
        }
    }
    
    var selectedTabIndex: Int {
        get {
            return MensaplanApp.tabValues.firstIndex(of: selectedTab ?? MensaplanApp.tabValues[0]) ?? 0
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MensaplanApp.tabValues.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
         return "Standard Tab"
     }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return "Hier kannst Du auswählen, welcher Tab beim Start der Mensaplan App geladen werden soll."
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "mensaLocationCell", for: indexPath)
        let row = indexPath.row
        
        cell.textLabel?.text = MensaplanApp.tabValues[row]
        cell.accessoryType = selectedTabIndex == row ? .checkmark : .none

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedTab = MensaplanApp.tabValues[indexPath.row]
        #if targetEnvironment(macCatalyst)
        HeinHelpers.showMessage(title: "Mensa auswählen", message: "Der Standort \(MensaplanApp.standorteValues[indexPath.row]) wurde ausgewählt.", on: self)
        #endif
    }
}
