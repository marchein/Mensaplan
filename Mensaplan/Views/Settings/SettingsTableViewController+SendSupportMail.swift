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

// MARK:- Mail Extension
extension SettingsTableViewController: MFMailComposeViewControllerDelegate {
    func sendSupportMail() {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setSubject("[Mensaplan] - Version \(MensaplanApp.versionString) (Build: \(MensaplanApp.buildNumber) - \(getReleaseTitle()))")
            mail.setToRecipients([MensaplanApp.mailAdress])
            mail.setMessageBody(NSLocalizedString("support_mail_body", comment: ""), isHTML: false)
            present(mail, animated: true)
        } else {
            print("No mail account configured")
            let mailErrorMessage = NSLocalizedString("mail_error", comment: "")
            showMessage(title: NSLocalizedString("Error", comment: ""), message: String(format: mailErrorMessage, MensaplanApp.mailAdress), on: self)
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}
