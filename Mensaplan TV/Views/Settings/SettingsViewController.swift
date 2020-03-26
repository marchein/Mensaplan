//
//  SettingsViewController.swift
//  Mensaplan TV
//
//  Created by Marc Hein on 26.03.20.
//  Copyright © 2020 Marc Hein. All rights reserved.
//

import UIKit
import TVOSPicker

class SettingsViewController: UIViewController {
    var selectedMensaIndex: Int?
    
    @IBOutlet weak var standortLabel: UILabel!
    @IBOutlet weak var priceControl: UISegmentedControl!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let selectedPrice = MensaplanApp.sharedDefaults.string(forKey: LocalKeys.selectedPrice) else {
            return
        }
        print(selectedPrice)

        standortLabel.text = getCurrentSelectedMensa()
        print(selectedMensaIndex)
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
                  print("\(item) selected at index \(MensaplanApp.standorteKeys[index])")
                  self.setNewLocation(selectedMensa: MensaplanApp.standorteKeys[index])
          })
      }
      
    @IBAction func priceChanged(_ sender: Any) {
        print(sender)
    }
    
    func setNewLocation(selectedMensa: String) {
          MensaplanApp.sharedDefaults.set(selectedMensa, forKey: LocalKeys.selectedMensa)
          standortLabel.text = getCurrentSelectedMensa()
      }
}
