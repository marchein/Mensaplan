//
//  MealViewController.swift
//  Mensaplan TV
//
//  Created by Marc Hein on 26.03.20.
//  Copyright © 2020 Marc Hein. All rights reserved.
//

import UIKit

class MealViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var meal: Meal?
    
    @IBOutlet weak var mealTitle: UILabel!
    @IBOutlet weak var mealImage: UIImageView!
    @IBOutlet weak var studentPrice: UILabel!
    @IBOutlet weak var workerPrice: UILabel!
    @IBOutlet weak var guestPrice: UILabel!
    @IBOutlet weak var informationTableView: UITableView!
    @IBOutlet weak var inhaltsstoffTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableViews()
        setupView()
    }
    
    func setupTableViews() {
        self.informationTableView.dataSource = self
        self.informationTableView.delegate = self
        
        self.inhaltsstoffTableView.dataSource = self
        self.inhaltsstoffTableView.delegate = self
    }
    
    func setupView() {
        if let meal = meal {
            mealTitle.text = meal.title
            studentPrice.text = meal.getFormattedPrice(price: meal.priceStudent)
            workerPrice.text = meal.getFormattedPrice(price: meal.priceWorker)
            guestPrice.text = meal.getFormattedPrice(price: meal.pricePublic)
            
            if let imageURL = meal.image {
                mealImage.sd_setImage(with: URL(string: imageURL), placeholderImage: #imageLiteral(resourceName: "no-image-meal"))
           }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let data = getDataFor(tableView: tableView)
        return data?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let data = getDataFor(tableView: tableView) {
            let cell = UITableViewCell()
            cell.textLabel?.text = data[indexPath.row].title
            return cell
        }
        return UITableViewCell()
    }
    
    func getDataFor(tableView: UITableView) -> [Stoff]? {
        switch tableView {
        case informationTableView:
            return meal?.zusatzStoffe
        case inhaltsstoffTableView:
            return meal?.inhaltsStoffe
        default:
            return nil
        }
    }
}
