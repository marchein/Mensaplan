//
//  InformationRowController.swift
//  Watchapp Extension
//
//  Created by Marc Hein on 26.02.20.
//  Copyright © 2020 Marc Hein. All rights reserved.
//

import WatchKit

class InformationRowController: NSObject {
    @IBOutlet var titleLabel: WKInterfaceLabel!

    var information: Stoff? {
        didSet {
            guard let information = information else { return }
            titleLabel.setText(information.title)
        }
    }
}
