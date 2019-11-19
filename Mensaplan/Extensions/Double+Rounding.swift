//
//  Double+Rounding.swift
//  Mensaplan
//
//  Created by Marc Hein on 18.11.19.
//  Copyright © 2019 Marc Hein. All rights reserved.
//

import Foundation

extension Double {
    // Rounds the double to decimal places value
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
