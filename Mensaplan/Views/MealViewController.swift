//
//  MealViewController.swift
//  Mensaplan
//
//  Created by Marc Hein on 22.10.19.
//  Copyright © 2019 Marc Hein. All rights reserved.
//

import UIKit

class MealViewController: UIViewController {
    
    var meal: Meal?

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var priceLabelStudent: UILabel!
    @IBOutlet weak var priceLabelWorker: UILabel!
    @IBOutlet weak var priceLabelPublic: UILabel!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let meal = meal else {
            return
        }
        nameLabel.text = meal.title
        priceLabelStudent.text = meal.getFormattedPrice(price: meal.priceStudent)
        priceLabelWorker.text = meal.getFormattedPrice(price: meal.priceWorker)
        priceLabelPublic.text = meal.getFormattedPrice(price: meal.pricePublic)
        if let image = meal.image {
            imageView.downloaded(from: image)
        }
    }
}
