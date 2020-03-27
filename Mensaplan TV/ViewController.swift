//
//  ViewController.swift
//  Mensaplan TV
//
//  Created by Marc Hein on 26.02.20.
//  Copyright © 2020 Marc Hein. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var mensaXML: MensaXML?
    var mensaData: Mensaplan?
    var isSetup = false
    
    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.estimatedRowHeight = 120
        self.tableView.rowHeight = UITableView.automaticDimension
        
        setupApp()
        
        mensaXML = MensaXML(url: URL(string: MensaplanApp.API)!)
        mensaXML?.loadXML(onDone: { (mensaPlanData) in
            print(mensaPlanData)
            MensaplanApp.sharedDefaults.set(mensaPlanData, forKey: LocalKeys.jsonData)
            self.loadJSONintoUI(data: mensaPlanData, local: false)
            MensaplanApp.sharedDefaults.set(Date.getCurrentDate(), forKey: LocalKeys.lastUpdate)
        })
        // Do any additional setup after loading the view.
    }
    
    func setupApp() {
        let isSetup  = MensaplanApp.sharedDefaults.bool(forKey: LocalKeys.isSetup)
        
        if !isSetup {
            MensaplanApp.sharedDefaults.set(true, forKey: LocalKeys.refreshOnStart)
            MensaplanApp.sharedDefaults.set(false, forKey: LocalKeys.showSideDish)
            MensaplanApp.sharedDefaults.set("standort-1", forKey: LocalKeys.selectedMensa)
            MensaplanApp.sharedDefaults.set("student", forKey: LocalKeys.selectedPrice)
            MensaplanApp.sharedDefaults.set(true, forKey: LocalKeys.isSetup)
            print("ViewController.swift - setupApp() - INITIAL SETUP DONE")
        } else {
            print("ViewController.swift - setupApp() - load local copy")
            if let localCopyOfData = MensaplanApp.sharedDefaults.data(forKey: LocalKeys.jsonData) {
                loadJSONintoUI(data: localCopyOfData, local: true)
            }
        }
    }
    
    func loadJSONintoUI(data: Data, local: Bool) {
        self.mensaData = try? JSONDecoder().decode(Mensaplan.self, from: data)
        
        DispatchQueue.main.async {
            print("ViewController.swift - loadJSONintoUI() - Successfully used \(local ? "local" : "remote") JSON in UI")
            print(self.mensaData)
            self.tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let mensaData = mensaData {
            /*if let selectedLocation = MensaplanApp.sharedDefaults.string(forKey: LocalKeys.selectedMensa), let locationPostition = MensaplanApp.standorteKeys.firstIndex(of: selectedLocation), mensaData.allDaysClosed(location: locationPostition) {
                return 1
            } else {
                return mensaData.plan.count
            }*/
            return mensaData.plan.count
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let isSetup = MensaplanApp.sharedDefaults.bool(forKey: LocalKeys.isSetup)
        if isSetup {
            let selectedMensa = MensaplanApp.sharedDefaults.string(forKey: LocalKeys.selectedMensa)
            let index = MensaplanApp.standorteKeys.firstIndex(of: selectedMensa!)!
            return MensaplanApp.standorteValues[index]
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print(indexPath.row)
        if let mensaData = self.mensaData {
            var dayData: LocationDay?
            let cell = tableView.dequeueReusableCell(withIdentifier: "locationCell", for: indexPath) as! DayTableViewCell
            cell.titleLabel.numberOfLines = 0
            cell.reasonLabel.numberOfLines = 0
            cell.dateLabel.numberOfLines = 0
            
            let selectedDay = mensaData.plan[indexPath.row]
            let selectedLocation = MensaplanApp.sharedDefaults.string(forKey: LocalKeys.selectedMensa)!
            for location in selectedDay.day {
                if location.title == selectedLocation {
                    dayData = location
                    break
                }
            }
            
            if let dayDataResult = dayData {
                let dateOfCell = dayDataResult.getDateValue()
                cell.titleLabel.text = dateSuffix(date: dateOfCell, string: getDayName(by: dateOfCell))
                cell.reasonLabel.text = nil
                cell.dateLabel.text = dayDataResult.getDate(showDay: false)
                
                /*if dayDataResult.closed || isDateOver(date: dateOfCell) || dayDataResult.data.counters.count == 0 {
                    cell.isUserInteractionEnabled = false
                    cell.titleLabel.isEnabled = false
                    cell.reasonLabel.isEnabled = false
                    cell.dateLabel.isEnabled = false
                    cell.accessoryType = .none
                    if dayDataResult.closed {
                        cell.titleLabel.textColor = .secondaryLabel
                        
                        if let locationPostition = MensaplanApp.standorteKeys.firstIndex(of: selectedLocation), mensaData.allDaysClosed(location: locationPostition) {
                            cell.titleLabel.text = "Geschlossen"
                        } else {
                            cell.titleLabel.text = dateSuffix(date: dateOfCell, string: getDayName(by: dateOfCell))
                        }
                        
                        cell.reasonLabel.text = dayDataResult.closedReason
                        cell.reasonLabel.isHidden = false
                    }
                } else {*/
                    cell.isUserInteractionEnabled = true
                    cell.titleLabel.isEnabled = true
                    cell.reasonLabel.isEnabled = true
                    cell.dateLabel.isEnabled = true
                    cell.accessoryType = .disclosureIndicator
                    cell.titleLabel.textColor = .label
                //}
                return cell
            } else {
                let cell = UITableViewCell()
                cell.textLabel?.text = "Es sind keine Daten vorhanden."
                return cell
            }
        } else {
            let cell = UITableViewCell()
            cell.textLabel?.text = "Es sind keine Daten vorhanden."
            return cell
        }
    }
    
}
