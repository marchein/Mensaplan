//
//  MealTableViewController.swift
//  Mensaplan
//
//  Created by Marc Hein on 13.11.19.
//  Copyright © 2019 Marc Hein. All rights reserved.
//

import UIKit

class MealTableViewController: UITableViewController {

    
    var meal: Meal!
    let dynamicSection = 4

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var priceLabelStudent: UILabel!
    @IBOutlet weak var priceLabelWorker: UILabel!
    @IBOutlet weak var priceLabelPublic: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if let _ = meal.zusatzStoffe {
            return 5
        }
        return 4
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 {
            return "Name des Gerichtes"
        } else if section == 2 {
            return "Preise"
        } else if section == 3, let _ = meal.zusatzStoffe {
            return "Zusatzinformationen"
        } else if section == 3 || section == 4 {
            return "Inhaltsstoffe"
        }
        return nil
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 2 {
            return 3
        } else if section == 3, let _ = meal.zusatzStoffe {
            return meal.zusatzStoffe?.count ?? 1
        } else if section == 3 || section == 4 {
            return meal.inhaltsStoffe?.count ?? 1
        } else {
            return 1
        }
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = indexPath.section
        let row = indexPath.row
        if section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "imageCell") as! ImageViewCell
            if let imageURL = meal.image {
                cell.mealImage.sd_setImage(with: URL(string: imageURL), placeholderImage: #imageLiteral(resourceName: "no-image-meal"))
            }
            return cell
        } else if section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "titleCell", for: indexPath)
            cell.textLabel?.text = meal.title
            return cell
        } else if section == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "priceCell", for: indexPath)
            if row == 0 {
                cell.textLabel?.text = "Studierende"
                cell.detailTextLabel?.text = meal.getFormattedPrice(price: meal.priceStudent)
            } else if row == 1 {
                cell.textLabel?.text = "Bedienstete"
                cell.detailTextLabel?.text =  meal.getFormattedPrice(price: meal.priceWorker)
            } else {
                cell.textLabel?.text = "Gäste"
                cell.detailTextLabel?.text = meal.getFormattedPrice(price: meal.pricePublic)
            }
            return cell
        } else if section == 3, let _ = meal.zusatzStoffe {
            let cell = tableView.dequeueReusableCell(withIdentifier: "inhaltsStoffCell")
            if let zusatzstoffe = meal.zusatzStoffe {
                cell?.textLabel?.text = zusatzstoffe[row].title
            } else {
                cell?.textLabel?.text = "Keine Zusatzinformationen vorhanden"
                cell?.textLabel?.isEnabled = false
            }
            return cell!
        } else if section == 3 || section == 4 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "inhaltsStoffCell")
            if let inhaltsstoffe = meal.inhaltsStoffe {
                cell?.textLabel?.text = inhaltsstoffe[row].title
            } else {
                cell?.textLabel?.text = "Keine Inhaltsstoffe vorhanden"
                cell?.textLabel?.isEnabled = false
            }
            return cell!
        } else {
            return UITableViewCell()
        }
    }

}
