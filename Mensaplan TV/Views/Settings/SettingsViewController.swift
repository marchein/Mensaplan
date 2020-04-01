//
//  SettingsViewController.swift
//  Mensaplan TV
//
//  Created by Marc Hein on 26.03.20.
//  Copyright © 2020 Marc Hein. All rights reserved.
//

import UIKit
import TVOSPicker

class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var selectedMensaIndex: Int?
    
    @IBOutlet weak var standortLabel: UILabel!
    @IBOutlet weak var settingsTableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.settingsTableView.dataSource = self
        self.settingsTableView.delegate = self
        
        guard let selectedPrice = MensaplanApp.sharedDefaults.string(forKey: LocalKeys.selectedPrice) else {
            return
        }
        print(selectedPrice)
        
        standortLabel.text = getCurrentSelectedMensa()
    }
    
    func getCurrentSelectedMensa() -> String {
        let selectedMensaValue = MensaplanApp.sharedDefaults.string(forKey: LocalKeys.selectedMensa)!
        selectedMensaIndex = MensaplanApp.standorteKeys.firstIndex(of: selectedMensaValue)
        return MensaplanApp.standorteValues[selectedMensaIndex!]
    }
    
    @IBAction func locationButtonTapped(_ sender: Any) {
        presentPicker(
            title: "Standort auswählen",
            subtitle: nil,
            dataSource: MensaplanApp.standorteValues,
            initialSelection: selectedMensaIndex ?? 0,
            onSelectItem: { item, index in
                self.setNewLocation(selectedMensa: MensaplanApp.standorteKeys[index])
        })
    }
    
    func setNewLocation(selectedMensa: String) {
        MensaplanApp.sharedDefaults.set(selectedMensa, forKey: LocalKeys.selectedMensa)
        standortLabel.text = getCurrentSelectedMensa()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Informationen"
        case 1:
            return "Sonstiges"
        default:
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        default:
            return 3
        }
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == 0 {
            return "Build Nummer: \(MensaplanApp.buildNumber) (\(getReleaseTitle()))"
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 && indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "appVersionCell")!
            cell.detailTextLabel?.text = MensaplanApp.versionString
            return cell
        } else {
            let cell = UITableViewCell()
            cell.textLabel?.text = "Test"
            return cell
        }
    }
}
