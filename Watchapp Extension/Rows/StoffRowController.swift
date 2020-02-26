//
//  StoffRowController.swift
//  Watchapp Extension
//
//  Created by Marc Hein on 26.02.20.
//  Copyright © 2020 Marc Hein. All rights reserved.
//

import WatchKit

class StoffRowController: NSObject {
    @IBOutlet var titleLabel: WKInterfaceLabel!

    var stoff: Stoff? {
        didSet {
            guard let stoff = stoff else { return }
            titleLabel.setText(stoff.title)
        }
    }
}
