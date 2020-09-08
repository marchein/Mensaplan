//
//  SettingsTableViewController+SendSupportMail.swift
//  Mensaplan
//
//  Created by Marc Hein on 21.10.19.
//  Copyright © 2019 Marc Hein. All rights reserved.
//

import Foundation
import MessageUI
import UIKit
import HeinHelpers

// MARK:- Mail Extension
extension SettingsTableViewController: MFMailComposeViewControllerDelegate {
    func sendSupportMail() {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setSubject("[Mensaplan] - Version \(MensaplanApp.versionString) (Build: \(MensaplanApp.buildNumber) - \(HeinHelpers.getReleaseTitle()))")
            mail.setToRecipients([MensaplanApp.mailAdress])
            mail.setMessageBody("Warum kontaktierst Du den Support?", isHTML: false)
            present(mail, animated: true)
        } else {
            print("No mail account configured")
            let mailErrorMessage = "Es ist kein E-Mail Konto in Apple Mail hinterlegt. Bitte kontaktiere uns unter %@"
            HeinHelpers.showMessage(title: "Fehler", message: String(format: mailErrorMessage, MensaplanApp.mailAdress), on: self)
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}
