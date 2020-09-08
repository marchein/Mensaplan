//
//  DetailTableViewController+TableView.swift
//  Mensaplan
//
//  Created by Marc Hein on 20.10.19.
//  Copyright © 2019 Marc Hein. All rights reserved.
//

import Foundation
import UIKit
import SDWebImage

extension DetailTableViewController {
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        if let day = mensaPlanDay {
            return day.counters.count
        }
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let day = mensaPlanDay {
            return day.counters[section].meals.count
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MealTableViewCell.cellIdentifier , for: indexPath) as! MealTableViewCell

        if let day = mensaPlanDay  {
            let meal = day.counters[indexPath.section].meals[indexPath.row]
            cell.mealTitleLabel.text = meal.title            
            
            if let imageView = cell.mealImage {
                imageView.roundCorners(radius: 5)
                
                if let imageURL = meal.image {
                    imageView.sd_setImage(with: URL(string: imageURL), placeholderImage: #imageLiteral(resourceName: "no-image-meal"))
                }
            }

            let selectedPrice = MensaplanApp.sharedDefaults.string(forKey: LocalKeys.selectedPrice)
            if selectedPrice == "student" {
                cell.mealPriceLabel.text = meal.getFormattedPrice(price: meal.priceStudent)
            } else if selectedPrice == "worker" {
                cell.mealPriceLabel.text = meal.getFormattedPrice(price: meal.priceWorker)
            } else if selectedPrice == "guest" {
                cell.mealPriceLabel.text = meal.getFormattedPrice(price: meal.pricePublic)
            }
            
            self.setIcons(in: cell, for: meal.zusatzStoffe)
            
        }
        return cell
    }
    
    
    fileprivate func setIcons(in cell: MealTableViewCell, for zusatzStoffe: [Stoff]?) {
        // max number of icons
        let MAX_ICONS = 3
        // how many icons have been added
        var addedIcons = 0
        
        // remove every icon for each cell
        cell.infoStackView.removeAllArrangedSubviews()
        
        if let zusatzstoffe = zusatzStoffe {
            for zusatzstoff in zusatzstoffe {
                if addedIcons < MAX_ICONS {
                    let imageView = UIImageView(image: getIcon(for: zusatzstoff))
                    imageView.image = imageView.image?.withRenderingMode(.alwaysTemplate)
                    if #available(iOS 13.0, *) {
                        imageView.tintColor = UIColor.label
                    } else {
                        imageView.tintColor = UIColor.black
                    }
                    imageView.heightAnchor.constraint(equalToConstant: 24).isActive = true
                    imageView.widthAnchor.constraint(equalToConstant: 24).isActive = true
                    cell.infoStackView.addArrangedSubview(imageView)
                    addedIcons += 1
                }
            }
        }
    }
    
    fileprivate func getIcon(for stoff: Stoff) -> UIImage {
        switch stoff.id {
        case 10320: // Vegetarisch
             return #imageLiteral(resourceName: "Vegetarisch")
        case 10321: // Vegan
             return #imageLiteral(resourceName: "Vegan")
        case 10322: // Schweinefleisch
            return #imageLiteral(resourceName: "Schwein")
        case 10323: // Rindfleisch
            return #imageLiteral(resourceName: "Kuh")
        case 10325: // Geflügel
             return #imageLiteral(resourceName: "Geflügel")
        case 10327: // Fisch
            return #imageLiteral(resourceName: "Fisch")
        case 10360:
            return #imageLiteral(resourceName: "Meeresfruechte_3x")
        default: // Kein Symbol vorhanden
            return #imageLiteral(resourceName: "Splash")
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let day = self.mensaPlanDay {
            return day.counters[section].label
        }
        return nil
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
    }

}
