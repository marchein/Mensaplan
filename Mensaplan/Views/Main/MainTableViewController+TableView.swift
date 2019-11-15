//
//  MainTableViewController+TableView.swift
//  Mensaplan
//
//  Created by Marc Hein on 18.10.19.
//  Copyright © 2019 Marc Hein. All rights reserved.
//

import Foundation
import UIKit

extension MainTableViewController {
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
       return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == 0 {
            if let mensaData = JSONData {
                return mensaData.plan.count
            }
            return 1
        }
        return 2
    }
        
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Configure the cell...
        if indexPath.section == 0 {
            if let mensaData = JSONData {
                var dayData: LocationDay?
                let cell = tableView.dequeueReusableCell(withIdentifier: "dayCell", for: indexPath)
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
                    cell.textLabel?.text = dateSuffix(date: dateOfCell, string: getDayName(by: dateOfCell))
                    cell.detailTextLabel?.text = dayDataResult.getDate(showDay: false)
                                        
                    if dayDataResult.closed || isDateOver(date: dateOfCell) || dayDataResult.data.counters.count == 0 {
                        cell.isUserInteractionEnabled = false
                        cell.textLabel?.isEnabled = false
                        cell.detailTextLabel?.isEnabled = false
                        if dayDataResult.closed {
                            cell.textLabel?.text = "\(dateSuffix(date: dateOfCell, string: getDayName(by: dateOfCell))) - \(dayDataResult.getDate(showDay: false)!)"
                            cell.detailTextLabel?.text = dayDataResult.closedReason
                        }
                    } else {
                        cell.isUserInteractionEnabled = true
                        cell.textLabel?.isEnabled = true
                        cell.detailTextLabel?.isEnabled = true
                    }
                    return cell
                }  else {
                   let cell = UITableViewCell()
                   cell.textLabel?.text = "Es sind keine Daten vorhanden."
                   return cell
               }
            } else {
                let cell = UITableViewCell()
                cell.textLabel?.text = "Es sind keine Daten vorhanden."
                return cell
            }
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "openingCell", for: indexPath)
            let isSetup = MensaplanApp.sharedDefaults.bool(forKey: LocalKeys.isSetup)
            if isSetup {
                let selectedMensa = MensaplanApp.sharedDefaults.string(forKey: LocalKeys.selectedMensa)
                let index = MensaplanApp.standorteKeys.firstIndex(of: selectedMensa!)!
                if indexPath.row == 0 {
                    cell.textLabel?.text = "Im Semester"
                    cell.detailTextLabel?.text = MensaplanApp.standorteOpenings[index].semester
                } else {
                    cell.textLabel?.text = "In den Semesterferien"
                    cell.detailTextLabel?.text = MensaplanApp.standorteOpenings[index].semesterFerien
                }
            }
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            let isSetup = MensaplanApp.sharedDefaults.bool(forKey: LocalKeys.isSetup)
            if isSetup {
                let selectedMensa = MensaplanApp.sharedDefaults.string(forKey: LocalKeys.selectedMensa)
                let index = MensaplanApp.standorteKeys.firstIndex(of: selectedMensa!)!
                return MensaplanApp.standorteValues[index]
            }
            return nil
        } else {
            return "Öffnungszeiten"
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == 0 {
            if let lastUpdate = MensaplanApp.sharedDefaults.string(forKey: LocalKeys.lastUpdate) {
                return "Letzte Aktualisierung: \(lastUpdate) Uhr"
            }
            return "Keine Aktualisierung vorgenommen"
            }
        return nil
    }
}
