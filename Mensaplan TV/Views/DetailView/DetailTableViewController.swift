//
//  DetailTableViewController.swift
//  Mensaplan TV
//
//  Created by Marc Hein on 26.03.20.
//  Copyright © 2020 Marc Hein. All rights reserved.
//

import UIKit
import SDWebImage

class DetailTableViewController: UITableViewController {
    
    var mensaPlanDay: MensaplanDay?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
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
    
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        if let currentCell = context.nextFocusedView as? MealTableViewCell {
            currentCell.mealTitleLabel.textColor = .black
            currentCell.mealPriceLabel.textColor = .black
            for icon in currentCell.infoStackView.subviews {
                if let icon = icon as? UIImageView {
                    icon.tintColor = .black
                }
            }
        }
        
        if let prevCell = context.previouslyFocusedView as? MealTableViewCell {
            prevCell.mealTitleLabel.textColor = .label
            prevCell.mealPriceLabel.textColor = .label
            
            for icon in prevCell.infoStackView.subviews {
                if let icon = icon as? UIImageView {
                    icon.tintColor = .label
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "mealCell"
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! MealTableViewCell
        
        if let day = mensaPlanDay  {
            let meal = day.counters[indexPath.section].meals[indexPath.row]
            cell.mealTitleLabel.text = meal.title
            
            if let imageView = cell.mealImage, let imageURL = meal.image {
                imageView.sd_setImage(with: URL(string: imageURL), placeholderImage: #imageLiteral(resourceName: "no-image-meal"))
            }
            
            cell.mealPriceLabel.text = "ab \(meal.getFormattedPrice(price: meal.priceStudent)!)"
            setIcons(in: cell, for: meal.zusatzStoffe)
            
        }
        return cell
    }
    
    func setIcons(in cell: MealTableViewCell, for zusatzStoffe: [Stoff]?) {
        // max number of icons
        let MAX_ICONS = 10
        // how many icons have been added
        var addedIcons = 0
        
        // remove every icon for each cell
        cell.infoStackView.removeAllArrangedSubviews()
        
        if let zusatzstoffe = zusatzStoffe {
            for zusatzstoff in zusatzstoffe {
                if addedIcons < MAX_ICONS {
                    let ICON_SIZE: CGFloat = 48.0
                    let imageView = UIImageView(image: getIcon(for: zusatzstoff))
                    imageView.image = imageView.image?.withRenderingMode(.alwaysTemplate)
                    imageView.tintColor = UIColor.label
                    imageView.heightAnchor.constraint(equalToConstant: ICON_SIZE).isActive = true
                    imageView.widthAnchor.constraint(equalToConstant: ICON_SIZE).isActive = true
                    cell.infoStackView.addArrangedSubview(imageView)
                    addedIcons += 1
                }
            }
        }
    }
    
    func getIcon(for stoff: Stoff) -> UIImage {
        switch stoff.id {
        case 10320:
            return #imageLiteral(resourceName: "Vegetarisch")
        case 10321:
            return #imageLiteral(resourceName: "Vegan")
        case 10322:
            return #imageLiteral(resourceName: "Schwein")
        case 10323:
            return #imageLiteral(resourceName: "Kuh")
        case 10325:
            return #imageLiteral(resourceName: "Geflügel")
        case 10327:
            return #imageLiteral(resourceName: "Fisch")
        default:
            return #imageLiteral(resourceName: "Splash")
        }
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showMealSegue" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let meal = mensaPlanDay!.counters[indexPath.section].meals[indexPath.row]
                let vc = segue.destination as! MealViewController
                vc.meal = meal
            } else {
                print("Oops, no row has been selected")
            }
        }
    }    
}
