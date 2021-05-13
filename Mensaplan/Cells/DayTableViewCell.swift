//
//  DayTableViewCell.swift
//  Mensaplan
//
//  Created by Marc Hein on 23.02.20.
//  Copyright © 2020 Marc Hein. All rights reserved.
//

import UIKit

class DayTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var reasonLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        reasonLabel.isHidden = true
        reasonLabel.text = nil
        
        // make date bold
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
