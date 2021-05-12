//
//  SettingsTableViewController+TableView.swift
//  Mensaplan
//
//  Created by Marc Hein on 21.10.19.
//  Copyright © 2019 Marc Hein. All rights reserved.
//

import Foundation
import UIKit
import StoreKit

extension SettingsTableViewController {
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == 0 {
            #if targetEnvironment(macCatalyst)
            return "Die Mensaplan Daten stammen vom Studierendenwerk Trier. Alle Angaben ohne Gewähr"
            #else
            return "Die Mensaplan Daten stammen vom Studierendenwerk Trier.\nAlle Angaben ohne Gewähr"
            #endif
        }
        return nil
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if MensaplanApp.devMode {
            return 4
        } else {
            return 3
        }
    }

    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let selectedCell = tableView.cellForRow(at: indexPath) else { return }
        tableView.deselectRow(at: indexPath, animated: true)
  
        switch (selectedCell) {
        case appSupportCell:
            sendSupportMail()
            break
        case rateAppCell:
            SKStoreReviewController.requestReview()
            break
        case appStoreCell:
            appStoreAction()
            break
        case developerCell:
            openSafariViewControllerWith(url: MensaplanApp.website)
            break
        default:
            if indexPath.section == 3 {
                handeDevAction(indexPath)
            }
            break
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if !MensaplanApp.appCanScan() ,indexPath.section == 1, indexPath.row == 1 {
            return 0.0
        }
            
        return tableView.rowHeight
    }
}
