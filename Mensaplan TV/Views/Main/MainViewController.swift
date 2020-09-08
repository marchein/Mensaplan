//
//  ViewController.swift
//  Mensaplan TV
//
//  Created by Marc Hein on 26.02.20.
//  Copyright © 2020 Marc Hein. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
    
    var mensaXML: MensaXML?
    var mensaData: Mensaplan?
    var isSetup = false
    var location: String?
    
    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.estimatedRowHeight = 120
        self.tableView.rowHeight = UITableView.automaticDimension
        
        setupApp()
        
        mensaXML = MensaXML(url: URL(string: MensaplanApp.API)!)
        refreshAction(self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let location = self.location {
            if location != MensaplanApp.sharedDefaults.string(forKey: LocalKeys.selectedMensa)! {
                self.tableView.reloadData()
            }
        }
    }
    
    func setupApp() {
        let isSetup  = MensaplanApp.sharedDefaults.bool(forKey: LocalKeys.isSetup)
        
        if !isSetup {
            MensaplanApp.sharedDefaults.set(true, forKey: LocalKeys.refreshOnStart)
            MensaplanApp.sharedDefaults.set(false, forKey: LocalKeys.showSideDish)
            MensaplanApp.sharedDefaults.set("standort-1", forKey: LocalKeys.selectedMensa)
            MensaplanApp.sharedDefaults.set("student", forKey: LocalKeys.selectedPrice)
            MensaplanApp.sharedDefaults.set(true, forKey: LocalKeys.isSetup)
            print("MainViewController.swift - setupApp() - INITIAL SETUP DONE")
        } else {
            print("MainViewController.swift - setupApp() - load local copy")
            if let localCopyOfData = MensaplanApp.sharedDefaults.data(forKey: LocalKeys.mensaplanJSONData) {
                loadJSONintoUI(data: localCopyOfData, local: true)
            }
        }
        self.location = MensaplanApp.sharedDefaults.string(forKey: LocalKeys.selectedMensa)
    }
    
    func loadJSONintoUI(data: Data, local: Bool) {
        self.mensaData = try? JSONDecoder().decode(Mensaplan.self, from: data)
        
        DispatchQueue.main.async {
            print("MainViewController.swift - loadJSONintoUI() - Successfully used \(local ? "local" : "remote") JSON in UI")
            self.tableView.reloadData()
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == MensaplanSegue.showDetail, let selectedDay = getSelectedMensaPlanDay() {
            return !selectedDay.closed
        }
        return true
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == MensaplanSegue.showDetail {
            let selectedDay = getSelectedMensaPlanDay()
            if let selectedDay = selectedDay, let vc = segue.destination as? DetailTableViewController {
                vc.mensaPlanDay = selectedDay.data
            } else {
                print("Oops, no row has been selected")
            }
        }
    }
    
    func getSelectedMensaPlanDay() -> LocationDay? {
        if let indexPath = self.tableView.indexPathForSelectedRow, let mensaData = self.mensaData {
            let selectedDay = mensaData.plan[indexPath.row]
            let selectedLocation = MensaplanApp.sharedDefaults.string(forKey: LocalKeys.selectedMensa)!
            for location in selectedDay.day {
                if location.title == selectedLocation  {
                    return location
                }
            }
        }
        return nil
    }
    
    @IBAction func refreshAction(_ sender: Any) {
        mensaXML?.loadXML(onDone: { (mensaPlanData) in
            MensaplanApp.sharedDefaults.set(mensaPlanData, forKey: LocalKeys.mensaplanJSONData)
            self.loadJSONintoUI(data: mensaPlanData, local: false)
            MensaplanApp.sharedDefaults.set(Date.getCurrentDate(), forKey: LocalKeys.lastUpdate)
        })
    }
}
