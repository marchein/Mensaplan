//
//  MainViewController+TableView.swift
//  Mensaplan TV
//
//  Created by Marc Hein on 26.03.20.
//  Copyright © 2020 Marc Hein. All rights reserved.
//

import UIKit

extension MainViewController:UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let mensaData = mensaData {
            if let selectedLocation = MensaplanApp.sharedDefaults.string(forKey: LocalKeys.selectedMensa), let locationPostition = MensaplanApp.standorteKeys.firstIndex(of: selectedLocation), mensaData.allDaysClosed(location: locationPostition) {
                return 1
            } else {
                return mensaData.plan.count
            }
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
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if let lastUpdate = MensaplanApp.sharedDefaults.string(forKey: LocalKeys.lastUpdate) {
            return "Letzte Aktualisierung: \(lastUpdate) Uhr"
        }
        return "Keine Aktualisierung vorgenommen"
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        if let currentCell = context.nextFocusedView as? DayTableViewCell {
            currentCell.titleLabel.textColor = .black
            currentCell.reasonLabel.textColor = .black
            currentCell.dateLabel.textColor = .black
        }
        
        if let prevCell = context.previouslyFocusedView as? DayTableViewCell {
            prevCell.titleLabel.textColor = .label
            prevCell.reasonLabel.textColor = .secondaryLabel
            prevCell.dateLabel.textColor = .secondaryLabel
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
                
                if dayDataResult.closed || isDateOver(date: dateOfCell) || dayDataResult.data.counters.count == 0 {
                    cell.isUserInteractionEnabled = false
                    cell.titleLabel.isEnabled = false
                    cell.reasonLabel.isEnabled = false
                    cell.dateLabel.isEnabled = false
                    cell.accessoryType = .none
                    if dayDataResult.closed {
                        cell.titleLabel.textColor = .secondaryLabel
                        
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
                    cell.titleLabel.textColor = .label
                    cell.dateLabel.isHidden = false

                }
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
