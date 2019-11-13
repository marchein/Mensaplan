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
