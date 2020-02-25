//
//  CounterRowController.swift
//  Watchapp Extension
//
//  Created by Marc Hein on 25.02.20.
//  Copyright © 2020 Marc Hein. All rights reserved.
//

import WatchKit

class CounterRowController: NSObject {

    @IBOutlet weak var counterNameLabel: WKInterfaceLabel!
    
    var counterName: String? {
        didSet {
            guard let counterName = counterName else { return }
            counterNameLabel.setText(counterName)
        }
    }
}
