//
//  HistoryTableViewCell.swift
//  Mensaplan
//
//  Created by Marc Hein on 06.05.21.
//  Copyright © 2021 Marc Hein. All rights reserved.
//
import UIKit

class HistoryTableViewCell: UITableViewCell {

    @IBOutlet weak var labelBalance: UILabel!
    @IBOutlet weak var labelDate: UILabel!
    @IBOutlet weak var labelCardID: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
