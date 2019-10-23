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
import AppKit

// MARK:- Mail Extension
extension SettingsTableViewController: MFMailComposeViewControllerDelegate {
    func sendSupportMail() {
        #if targetEnvironment(macCatalyst)
        let message = "Bei Fragen und Anregungen kannst uns jeder Zeit unter %@ erreichen."
        showMessage(title: "Support Anfrage", message: String(format: message, MensaplanApp.mailAdress), on: self)
        #else
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setSubject("[Mensaplan] - Version \(MensaplanApp.versionString) (Build: \(MensaplanApp.buildNumber) - \(getReleaseTitle()))")
            mail.setToRecipients([MensaplanApp.mailAdress])
            mail.setMessageBody("Warum kontaktierst Du den Support?", isHTML: false)
            present(mail, animated: true)
        } else {
            print("No mail account configured")
            let mailErrorMessage = "Es ist kein E-Mail Konto in Apple Mail hinterlegt. Bitte kontaktiere uns unter %@"
            showMessage(title: "Fehler", message: String(format: mailErrorMessage, MensaplanApp.mailAdress), on: self)
        }
        #endif
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}
