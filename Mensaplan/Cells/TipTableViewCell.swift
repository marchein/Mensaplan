//
//  TipTableViewCell.swift
//  Mensaplan
//
//  Created by Marc Hein on 12.05.21.
//  Copyright © 2021 Marc Hein. All rights reserved.
//

import UIKit

class TipTableViewCell: UITableViewCell {
    @IBOutlet weak var tipTitle: UILabel!
    @IBOutlet weak var tipDesc: UILabel!
    @IBOutlet weak var purchaseButton: BorderedButton!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
