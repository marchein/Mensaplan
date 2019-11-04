//
//  MealTableViewCell.swift
//  Mensaplan
//
//  Created by Marc Hein on 20.10.19.
//  Copyright © 2019 Marc Hein. All rights reserved.
//

import UIKit

class MealTableViewCell: UITableViewCell {

    @IBOutlet weak var mealImage: UIImageView!
    @IBOutlet weak var mealTitleLabel: UILabel!
    @IBOutlet weak var mealPriceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
       
        self.imageView?.image = #imageLiteral(resourceName: "no-image-meal-small")
        
        layoutSubviews()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let itemSize = CGSize.init(width: 100, height: 75)
        UIGraphicsBeginImageContextWithOptions(itemSize, false, UIScreen.main.scale);
        let imageRect = CGRect.init(origin: CGPoint.zero, size: itemSize)
        self.imageView?.image!.draw(in: imageRect)
        self.imageView?.image! = UIGraphicsGetImageFromCurrentImageContext()!;
        UIGraphicsEndImageContext();
        
        self.imageView?.contentMode = .scaleAspectFill
    }

}
