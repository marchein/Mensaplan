//
//  UIViewController+SafariActions.swift
//  Mensaplan
//
//  Created by Marc Hein on 21.10.19.
//  Copyright © 2019 Marc Hein. All rights reserved.
//

import Foundation
import SafariServices
import UIKit

// MARK:- Safari Extension
extension UIViewController: SFSafariViewControllerDelegate {
    public func openTwitter(username: String) {
        let tweetbotURL = URL(string: "tweetbot:///user_profile/\(username)")!
        let twitterURL = URL(string: "twitter:///user?screen_name=\(username)")!
        let webURL = "https://twitter.com/\(username)"
        let application = UIApplication.shared
        if application.canOpenURL(tweetbotURL as URL) {
            application.open(tweetbotURL as URL)
        } else if application.canOpenURL(twitterURL as URL) {
            application.open(twitterURL as URL)
        } else {
            openSafariViewControllerWith(url: webURL)
        }
    }
    
    public func openSafariViewControllerWith(url: String) {
        guard let safariURL = URL(string: url) else { return }
        
        let safariVC = SFSafariViewController(url: safariURL)
        self.present(safariVC, animated: true, completion: nil)
        safariVC.delegate = self
    }
    
    public func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}
