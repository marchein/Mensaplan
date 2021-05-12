//
//  SettingsTableViewController+Developer.swift
//  Mensaplan
//
//  Created by Marc Hein on 07.05.21.
//  Copyright © 2021 Marc Hein. All rights reserved.
//

import UIKit


extension SettingsTableViewController {
    func handeDevAction(_ indexPath: IndexPath) {
        print(indexPath)
        let numberOfItemsInDevSection = tableView.numberOfRows(inSection: tableView.numberOfSections - 1)
        if indexPath.row == 0 {
            generateDemoData()
        } else if indexPath.row == numberOfItemsInDevSection - 1 {
            disableDevMode()
        }
    }
    
    fileprivate func generateDemoData() {
        let alert = UIAlertController(title: "Some Title", message: "Enter a text", preferredStyle: .alert)

        alert.addTextField(configurationHandler: { (textField) -> Void in
                            textField.placeholder = "Number of entries" }
        )
        alert.addTextField(configurationHandler: { (textField) -> Void in
                            textField.placeholder = "Max balance of cards" }
        )

        alert.addAction(UIAlertAction(title: "Generate", style: .default, handler: { [weak alert] (action) -> Void in
            if let textfields = alert?.textFields {
                let pattern = "[0-9]*"
                let result = textfields[0].text!.range(of: pattern, options:.regularExpression)
                print(result)
            }
        }))

        // 4. Present the alert.
        self.present(alert, animated: true, completion: nil)
    }
    
    fileprivate func disableDevMode() {
        MensaplanApp.devMode = false
        view.makeToast("Disabled development mode!", duration: 1.0, position: .center)
        tableView.reloadData()
    }
}
