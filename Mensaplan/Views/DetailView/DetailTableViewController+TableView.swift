//
//  DetailTableViewController+TableView.swift
//  Mensaplan
//
//  Created by Marc Hein on 20.10.19.
//  Copyright © 2019 Marc Hein. All rights reserved.
//

import Foundation
import UIKit

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

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "mealCell", for: indexPath) as! MealTableViewCell

        if let day = mensaPlanDay  {
            let meal = day.counters[indexPath.section].meals[indexPath.row]
            //cell.mealImage.image = #imageLiteral(resourceName: "Meal")
            cell.mealTitleLabel.text = meal.title + "\n"
            
            if let imageView = cell.mealImage, let image = meal.image {
                imageView.downloaded(from: image)
            }

            let selectedPrice = MensaplanApp.sharedDefaults.string(forKey: LocalKeys.selectedPrice)
            if selectedPrice == "student" {
                cell.mealPriceLabel.text = meal.getFormattedPrice(price: meal.priceStudent)
            } else if selectedPrice == "worker" {
                cell.mealPriceLabel.text = meal.getFormattedPrice(price: meal.priceWorker)
            } else if selectedPrice == "guest" {
                cell.mealPriceLabel.text = meal.getFormattedPrice(price: meal.pricePublic)
            }
            
            cell.infoStackView.removeAllArrangedSubviews()
            
            let MAX_ICONS = 3
            var addedIcons = 0
            if let zusatzstoffe = meal.zusatzStoffe {
                for zusatzstoff in zusatzstoffe {
                    var image: UIImage?
                    switch zusatzstoff.id {
                    case 10320:
                        image = #imageLiteral(resourceName: "Vegetarisch")
                        break
                    case 10321:
                        image = #imageLiteral(resourceName: "Vegan")
                        break
                    case 10322:
                        image = #imageLiteral(resourceName: "Schwein")
                        break
                    case 10323:
                        image = #imageLiteral(resourceName: "Kuh")
                        break
                    case 10325:
                        image = #imageLiteral(resourceName: "Geflügel")
                        break
                    case 10327:
                        image = #imageLiteral(resourceName: "Fisch")
                        break
                    default:
                        break
                    }
                    if let image = image {
                        if addedIcons < MAX_ICONS {
                            let imageView = UIImageView(image: image)
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
            
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let day = mensaPlanDay {
            return day.counters[section].label
        }
        return nil
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

}
