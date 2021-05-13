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
        return 3
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {      
        if section == 0 {
            if let mensaContainer = self.mensaContainer, let mensaData = mensaContainer.mensaData {
                if let selectedLocation = MensaplanApp.userDefaults.string(forKey: LocalKeys.selectedMensa), let locationPostition = MensaplanApp.standorteKeys.firstIndex(of: selectedLocation), mensaData.allDaysClosed(location: locationPostition) {
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
            return getDayCell(indexPath)
        } else if indexPath.section == 1 {
            return getOpeningCell(indexPath)
        } else {
            return getMensamobilCell(indexPath)
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == 0 {
            if let lastUpdate = MensaplanApp.userDefaults.string(forKey: LocalKeys.lastUpdate), let dateObj = getDate(from: lastUpdate)  {
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
        if indexPath.section == 1 {
            openSafariViewControllerWith(url: MensaplanApp.OPENINGS_URL)
        } else  if indexPath.section == 2 {
            openSafariViewControllerWith(url: MensaplanApp.MENSAMOBIL_URL)
        }

        #if targetEnvironment(macCatalyst)
        tableView.perform(#selector(UIResponder.resignFirstResponder), with: nil, afterDelay: 0.01)
        #endif
    }
    
    fileprivate func getEmptyCell() -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = "Es sind keine Daten vorhanden."
        return cell
    }
    
    fileprivate func getMultilineCell() -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        cell.accessoryType = .disclosureIndicator
        cell.textLabel?.font = UIFont.preferredFont(forTextStyle: .headline)
        cell.detailTextLabel?.font = UIFont.preferredFont(forTextStyle: .footnote)
        cell.detailTextLabel?.textColor = UIColor.secondaryLabel
        cell.detailTextLabel?.numberOfLines = 0
        return cell
    }
    
    fileprivate func getOpeningCell(_ indexPath: IndexPath) -> UITableViewCell {
        let cell = getMultilineCell()
        cell.textLabel?.text = "Öffnungszeiten anzeigen"
        cell.detailTextLabel?.text = "Zeigt die Öffnungszeiten auf der Studiwerk-Website an"
        return cell
    }
    
    fileprivate func getMensamobilCell(_ indexPath: IndexPath) -> UITableViewCell {
        let cell = getMultilineCell()
        cell.textLabel?.text = "Essensplan des Mensamobils"
        cell.detailTextLabel?.text = "Zeigt den Essensplan des Mensamobils auf der Studiwerk-Website an"
        return cell
    }
    
    fileprivate func enableCell(_ cell: DayTableViewCell) {
        cell.isUserInteractionEnabled = true
        cell.titleLabel.isEnabled = true
        cell.reasonLabel.isEnabled = true
        cell.dateLabel.isEnabled = true
        cell.accessoryType = .disclosureIndicator
        cell.dateLabel.isHidden = false
        cell.titleLabel.textColor = .label
    }
    
    fileprivate func configureNoAvailableMealsCell(_ cell: DayTableViewCell, _ noMealsForDay: Bool, _ dateOfCell: Date) {
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
    }
    
    fileprivate func configureClosedCell(_ dayDataResult: LocationDay, _ cell: DayTableViewCell, _ selectedLocation: String, _ mensaData: Mensaplan, _ dateOfCell: Date) {
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
    }
    
    fileprivate func setDayCell(_ cell: DayTableViewCell, _ dayDataResult: LocationDay, _ selectedLocation: String, _ mensaData: Mensaplan) -> UITableViewCell {
        cell.reasonLabel.isHidden = true
        let dateOfCell = dayDataResult.getDateValue()
        cell.titleLabel.text = HeinHelpers.dateSuffix(date: dateOfCell, string: HeinHelpers.getDayName(by: dateOfCell))
        cell.reasonLabel.text = nil
        cell.dateLabel.text = dayDataResult.getDate(showDay: false)
        let noMealsForDay = dayDataResult.data.counters.count == 0
        if dayDataResult.closed || HeinHelpers.isDateOver(date: dateOfCell) || noMealsForDay {
            configureNoAvailableMealsCell(cell, noMealsForDay, dateOfCell)
            configureClosedCell(dayDataResult, cell, selectedLocation, mensaData, dateOfCell)
        } else {
            enableCell(cell)
        }
        return cell
    }
    
    fileprivate func getDayCell(_ indexPath: IndexPath) -> UITableViewCell {
        if let mensaContainer = self.mensaContainer, let mensaData = mensaContainer.mensaData {
            var dayData: LocationDay?
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "dayCell", for: indexPath) as? DayTableViewCell else { return UITableViewCell()}
            cell.titleLabel.numberOfLines = 0
            cell.reasonLabel.numberOfLines = 0
            cell.dateLabel.numberOfLines = 0
            let selectedDay = mensaData.plan[indexPath.row]
            let selectedLocation = MensaplanApp.userDefaults.string(forKey: LocalKeys.selectedMensa)!
            for location in selectedDay.day {
                if location.title == selectedLocation {
                    dayData = location
                    break
                }
            }
            if let dayDataResult = dayData {
                return setDayCell(cell, dayDataResult, selectedLocation, mensaData)
            }  else {
                return getEmptyCell()
            }
        } else {
            return getEmptyCell()
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            let isSetup = MensaplanApp.userDefaults.bool(forKey: LocalKeys.isSetup)
            if isSetup {
                let selectedMensa = MensaplanApp.userDefaults.string(forKey: LocalKeys.selectedMensa)
                let index = MensaplanApp.standorteKeys.firstIndex(of: selectedMensa!)!
                return MensaplanApp.standorteValues[index]
            }
            return nil
        } else if section == 1 {
            return "Öffnungszeiten"
        } else {
            return "Mensamobil"
        }
    }
    
    func getDate(from: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy - HH:mm"
        return dateFormatter.date(from: from)
    }
}
