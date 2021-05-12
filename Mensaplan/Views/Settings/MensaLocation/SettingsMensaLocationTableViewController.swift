//
//  SettingsMensaLocationTableViewController.swift
//  Mensaplan
//
//  Created by Marc Hein on 05.08.20.
//  Copyright © 2020 Marc Hein. All rights reserved.
//

import UIKit
import HeinHelpers

class SettingsMensaLocationTableViewController: UITableViewController {
    var selectedLocation: String? {
        get {
            return MensaplanApp.sharedDefaults.string(forKey: LocalKeys.selectedMensa)
        }
        
        set {
            MensaplanApp.sharedDefaults.set(newValue, forKey: LocalKeys.selectedMensa)
            var indexPaths: [IndexPath] = []
            for i in 0..<self.tableView(self.tableView, numberOfRowsInSection: tableView.numberOfSections) {
                if i != selectedLocationIndex {
                    let indexPath = IndexPath(row: i, section: 0)
                    indexPaths.append(indexPath)
                    let cell = self.tableView(self.tableView, cellForRowAt: indexPath)
                    cell.accessoryType = .none
                }
            }
            MensaplanApp.getMainVC()?.refreshAction(self)
            indexPaths.append(IndexPath(row: selectedLocationIndex, section: 0))
            
            self.tableView.reloadRows(at: indexPaths, with: .automatic)
        }
    }
    
    var selectedLocationIndex: Int {
        get {
            return MensaplanApp.standorteKeys.firstIndex(of: selectedLocation ?? MensaplanApp.standorteKeys[0]) ?? 0
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
        return MensaplanApp.standorteKeys.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
         return "Standort"
     }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "mensaLocationCell", for: indexPath)
        let row = indexPath.row
        
        cell.textLabel?.text = MensaplanApp.standorteValues[row]
        cell.accessoryType = selectedLocationIndex == row ? .checkmark : .none

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedLocation = MensaplanApp.standorteKeys[indexPath.row]
        #if targetEnvironment(macCatalyst)
        HeinHelpers.showMessage(title: "Mensa auswählen", message: "Der Standort \(MensaplanApp.standorteValues[indexPath.row]) wurde ausgewählt.", on: self)
        #endif
    }
}
