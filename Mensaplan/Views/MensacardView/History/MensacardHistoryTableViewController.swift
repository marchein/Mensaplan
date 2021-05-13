//
//  MensacardHistoryTableViewController.swift
//  Mensaplan
//
//  Created by Marc on 05.05.2021.
//  Copyright © 2021 Marc Hein. All rights reserved.
//

import UIKit
import SQLite3

class MensacardHistoryTableViewController: UITableViewController {

    let db = MensaDatabase()
    var historyStore : [HistoryItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()


        self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        historyStore = db.getEntries()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return historyStore.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "historyCell", for: indexPath) as! HistoryTableViewCell

        cell.labelBalance.text = String(
            format: "%.2f €",
            historyStore[indexPath.row].balance
        )
        cell.labelDate.text = historyStore[indexPath.row].date
        cell.labelCardID.text = historyStore[indexPath.row].cardID

        return cell
    }

    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            db.deleteRecord(id: historyStore[indexPath.row].id)
            historyStore = db.getEntries()
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            if let mensacardVC = navigationController?.children.first as? MensacardViewController {
                mensacardVC.setMensacardData()
                mensacardVC.setupChart()
            }
            
            if historyStore.count == 0 {
                navigationController?.popToRootViewController(animated: true)
            }
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
}
