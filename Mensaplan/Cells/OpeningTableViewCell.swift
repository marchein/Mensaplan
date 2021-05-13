//
//  OpeningTableViewCell.swift
//  Mensaplan
//
//  Created by Marc Hein on 05.05.2021.
//  Copyright © 2021 Marc Hein. All rights reserved.
//

import UIKit

class OpeningTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
