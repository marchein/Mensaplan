//
//  ImageViewCell.swift
//  Mensaplan
//
//  Created by Marc Hein on 20.10.19.
//  Copyright © 2019 Marc Hein. All rights reserved.
//

import UIKit

class ImageViewCell: UITableViewCell {
    static let Identifier = "ImageViewCell"
    
    @IBOutlet weak var mealImage: UIImageView!
    
    var imageURL: String? {
        didSet {
            if let imageURL = self.imageURL {
                self.mealImage.sd_setImage(with: URL(string: imageURL), placeholderImage: #imageLiteral(resourceName: "no-image-meal"))
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
