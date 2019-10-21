//
//  DetailTableViewController.swift
//  Mensaplan
//
//  Created by Marc Hein on 20.10.19.
//  Copyright © 2019 Marc Hein. All rights reserved.
//

import UIKit

class DetailTableViewController: UITableViewController {
    
    var mensaPlanDay: MensaplanDay?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = mensaPlanDay?.getDate(showDay: false)

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
}
