//
//  SettingsTableViewController+Developer.swift
//  Mensaplan
//
//  Created by Marc Hein on 07.05.21.
//  Copyright © 2021 Marc Hein. All rights reserved.
//

import UIKit

#if !targetEnvironment(macCatalyst)
extension SettingsTableViewController {
    func handeDevAction(_ indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            generateDemoData()
            break
        case 1:
            clearDatabase()
            break
        default:
            disableDevMode()
            break
        }
    }
    
    fileprivate func generateDemoData() {
        let alert = UIAlertController(title: "Generate demo mensacard data", message: "Entered input must be a number!", preferredStyle: .alert)

        alert.addTextField(configurationHandler: { (textField) -> Void in
            textField.placeholder = "Number of entries"
            textField.keyboardType = .numberPad
        })
        
        alert.addTextField(configurationHandler: { (textField) -> Void in
            textField.placeholder = "Max balance of cards"
            textField.keyboardType = .numberPad
        })

        alert.addAction(UIAlertAction(title: "Generate", style: .default, handler: { [weak alert] (action) -> Void in
            if let textfields = alert?.textFields {
                let numberOfEntriesTextfield = textfields[0]
                let maxBalanceTextfield = textfields[1]
                
                guard let numberOfEntries = Int(numberOfEntriesTextfield.text ?? "0"), let maxBalance = Int(maxBalanceTextfield.text ?? "0") else {
                    return
                }

                let db = MensaDatabase()
                let cardNumber = String(Int.random(in: 10000000...10000000000))
                for i in (0..<numberOfEntries).reversed() {
                    let balance = Double.random(in: 0...Double(maxBalance))
                    let lastTransaction = Double.random(in: 0...Double(maxBalance/2))
                    db.insertRecord(
                        balance: balance,
                        lastTransaction: lastTransaction,
                        date: Date.getCurrentDate(short: false, date: Date() - TimeInterval((i * 3600 * 24))),
                        cardID: cardNumber
                    )
                }
                self.view.makeToast("Generated \(numberOfEntries) demo entries!", duration: 1.0, position: .center)
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    fileprivate func clearDatabase() {
        let db = MensaDatabase()
        db.clearHistory()
    }
    
    fileprivate func disableDevMode() {
        MensaplanApp.devMode = false
        view.makeToast("Disabled development mode!", duration: 1.0, position: .center)
        tableView.reloadData()
    }
}
#endif
