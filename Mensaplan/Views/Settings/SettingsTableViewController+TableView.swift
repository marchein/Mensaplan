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

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 && indexPath.row == 3 {
            return isPickerHidden ? 0 : 165
        }
        return UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == 0 {
            return "Die Mensaplan Daten stammen vom Studierendenwerk Trier.\nAlle Angaben ohne Gewähr."
        } else if section == 1 {
            return "Build Nummer: \(MensaplanApp.buildNumber) (\(getReleaseTitle()))"
        }
        return nil
    }

    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let selectedCell = tableView.cellForRow(at: indexPath) else { return }
        tableView.deselectRow(at: indexPath, animated: true)
  
        switch (selectedCell) {
        case mensaNameCell:
            isPickerHidden = !isPickerHidden
            tableView.beginUpdates()
            tableView.endUpdates()
            break
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
            break
        }
    }
}
