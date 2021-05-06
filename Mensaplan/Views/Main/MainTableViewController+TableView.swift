//
//  MainTableViewController+TableView.swift
//  Mensaplan
//
//  Created by Marc Hein on 18.10.19.
//  Copyright © 2019 Marc Hein. All rights reserved.
//

import Foundation
import UIKit
import HeinHelpers

extension MainTableViewController {
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {      
        if section == 0 {
            if let mensaContainer = self.mensaContainer, let mensaData = mensaContainer.mensaData {
                if let selectedLocation = MensaplanApp.sharedDefaults.string(forKey: LocalKeys.selectedMensa), let locationPostition = MensaplanApp.standorteKeys.firstIndex(of: selectedLocation), mensaData.allDaysClosed(location: locationPostition) {
                    return 1
                } else {
                    return mensaData.plan.count
                }
            }
            return 1
        } else {
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Configure the cell...
        if indexPath.section == 0 {
            if let mensaContainer = self.mensaContainer, let mensaData = mensaContainer.mensaData {
                var dayData: LocationDay?
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "dayCell", for: indexPath) as? DayTableViewCell else { return UITableViewCell()}
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
                    cell.reasonLabel.isHidden = true
                    let dateOfCell = dayDataResult.getDateValue()
                    cell.titleLabel.text = HeinHelpers.dateSuffix(date: dateOfCell, string: HeinHelpers.getDayName(by: dateOfCell))
                    cell.reasonLabel.text = nil
                    cell.dateLabel.text = dayDataResult.getDate(showDay: false)
                    let noMealsForDay = dayDataResult.data.counters.count == 0
                    if dayDataResult.closed || HeinHelpers.isDateOver(date: dateOfCell) || noMealsForDay {
                        cell.isUserInteractionEnabled = false
                        cell.titleLabel.isEnabled = false
                        cell.reasonLabel.isEnabled = false
                        cell.dateLabel.isEnabled = false
                        cell.accessoryType = .none
                        if noMealsForDay {
                            cell.titleLabel.textColor = .secondaryLabel

                            cell.titleLabel.text = HeinHelpers.dateSuffix(date: dateOfCell, string: HeinHelpers.getDayName(by: dateOfCell))
                            
                            cell.reasonLabel.text = "Für diesen Tag gibt es keine Gerichte an diesem Standort"
                            cell.reasonLabel.isHidden = false
                        }
                        if dayDataResult.closed {
                            cell.titleLabel.textColor = .secondaryLabel
                        
                            if let locationPostition = MensaplanApp.standorteKeys.firstIndex(of: selectedLocation), mensaData.allDaysClosed(location: locationPostition) {
                                cell.titleLabel.text = "Geschlossen"
                                cell.dateLabel.isHidden = true
                            } else {
                                cell.titleLabel.text = HeinHelpers.dateSuffix(date: dateOfCell, string: HeinHelpers.getDayName(by: dateOfCell))
                            }
                            
                            cell.reasonLabel.text = dayDataResult.closedReason
                            cell.reasonLabel.isHidden = false
                        }
                    } else {
                        cell.isUserInteractionEnabled = true
                        cell.titleLabel.isEnabled = true
                        cell.reasonLabel.isEnabled = true
                        cell.dateLabel.isEnabled = true
                        cell.accessoryType = .disclosureIndicator
                        cell.dateLabel.isHidden = false
                        cell.titleLabel.textColor = .label
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
            let cell = tableView.dequeueReusableCell(withIdentifier: "openingCell", for: indexPath) as! OpeningTableViewCell
            cell.titleLabel?.text = "Öffnungszeiten anzeigen"
            cell.detailTextLabel?.numberOfLines = 0
            cell.detailTextLabel?.text = "Zeigt die Öffnungszeiten auf der Studiwerk-Website an"
            return cell
        }
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
            if let lastUpdate = MensaplanApp.sharedDefaults.string(forKey: LocalKeys.lastUpdate), let dateObj = getDate(from: lastUpdate)  {
                #if targetEnvironment(macCatalyst)
                return "Letzte Aktualisierung: \(Date.getCurrentDate(short: true, date: dateObj)) Uhr"
                #else
                return "Letzte Aktualisierung: \(lastUpdate) Uhr"
                #endif
            }
            return "Keine Aktualisierung vorgenommen"
        }
        return nil
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath), ((cell as? OpeningTableViewCell) != nil) {
            openSafariViewControllerWith(url: MensaplanApp.OPENINGS_URL)
        }

        #if targetEnvironment(macCatalyst)
        tableView.perform(#selector(UIResponder.resignFirstResponder), with: nil, afterDelay: 0.01)
        #endif
    }
    
    func getDate(from: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy - HH:mm"
        return dateFormatter.date(from: from)
    }
}
