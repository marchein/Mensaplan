//
//  MainTableViewController+TableView.swift
//  Mensaplan
//
//  Created by Marc Hein on 18.10.19.
//  Copyright © 2019 Marc Hein. All rights reserved.
//

import Foundation
import UIKit
import CoreNFC

extension MainTableViewController {
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if #available(iOS 13.0, *), MensaplanApp.canScan {
            return 3
        } else {
            return 2
        }
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
        } else if #available(iOS 13.0, *), MensaplanApp.canScan, section == 1 {
            return 3
        } else {
            return 2
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Configure the cell...
        if indexPath.section == 0 {
            if let mensaContainer = self.mensaContainer, let mensaData = mensaContainer.mensaData {
                var dayData: LocationDay?
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "newDayCell", for: indexPath) as? DayTableViewCell else { return UITableViewCell()}
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
                    
                    if dayDataResult.closed || isDateOver(date: dateOfCell) || dayDataResult.data.counters.count == 0 {
                        cell.isUserInteractionEnabled = false
                        cell.titleLabel.isEnabled = false
                        cell.reasonLabel.isEnabled = false
                        cell.dateLabel.isEnabled = false
                        cell.accessoryType = .none
                        if dayDataResult.closed {
                            if #available(iOS 13.0, *) {
                                cell.titleLabel.textColor = .secondaryLabel
                            } else {
                                cell.titleLabel.textColor = UIColor(red: 60.0, green: 60.0, blue: 67.0, alpha: 0.6)
                            }

                            if let locationPostition = MensaplanApp.standorteKeys.firstIndex(of: selectedLocation), mensaData.allDaysClosed(location: locationPostition) {
                                cell.titleLabel.text = "Geschlossen"
                                cell.dateLabel.isHidden = true
                            } else {
                                cell.titleLabel.text = dateSuffix(date: dateOfCell, string: getDayName(by: dateOfCell))
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
                        if #available(iOS 13.0, *) {
                            cell.titleLabel.textColor = .label
                        } else {
                            cell.titleLabel.textColor = .black
                        }
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
        } else if #available(iOS 13.0, *), MensaplanApp.canScan, indexPath.section == 1 {
            if indexPath.row < (tableView.numberOfRows(inSection: 1) - 1), let mensaData = self.mensaContainer {
                let cell = tableView.dequeueReusableCell(withIdentifier: "cardCell", for: indexPath)
                let data: [HistoryItem] = mensaData.db.getEntries()
                if data.count == 0 {
                    cell.textLabel?.isEnabled = false
                    cell.detailTextLabel?.isEnabled = false
                    cell.textLabel?.textColor = .secondaryLabel
                } else {
                    cell.textLabel?.textColor = .label

                }
                if indexPath.row == 0 {
                    cell.textLabel?.text = "Guthaben"
                    cell.detailTextLabel?.text = data.count > 0 ? String(format: "%.2f €", data[0].balance) : "0,00 €"
                } else if indexPath.row == 1 {
                    cell.textLabel?.text = "Letzte Transaktion"
                    cell.detailTextLabel?.text =  data.count > 0 ? String(format: "%.2f €", data[0].lastTransaction) : "0,00 €"
                }
                return cell
            } else {
                return tableView.dequeueReusableCell(withIdentifier: "scanCell", for: indexPath)
            }
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "openingCell", for: indexPath)
            cell.textLabel?.numberOfLines = 0
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
    
    
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            let isSetup = MensaplanApp.sharedDefaults.bool(forKey: LocalKeys.isSetup)
            if isSetup {
                let selectedMensa = MensaplanApp.sharedDefaults.string(forKey: LocalKeys.selectedMensa)
                let index = MensaplanApp.standorteKeys.firstIndex(of: selectedMensa!)!
                return MensaplanApp.standorteValues[index]
            }
            return nil
        } else if #available(iOS 13.0, *), MensaplanApp.canScan, section == 1 {
            return "Guthaben"
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
        } else if #available(iOS 13.0, *), MensaplanApp.canScan, section == 1 {
            if let mensaData = self.mensaContainer {
                let data: [HistoryItem] = mensaData.db.getEntries()
                if data.count > 0 {
                    return "Einlesedatum: \(data[0].date) Uhr"
                }
            }
            return "Guthaben wurde noch nicht eingelesen"
        }
        return nil
    }
}
