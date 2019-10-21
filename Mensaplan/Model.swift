//
//  Model.swift
//  Mensaplan
//
//  Created by Marc Hein on 21.10.19.
//  Copyright © 2019 Marc Hein. All rights reserved.
//

import Foundation

struct LocalKeys {
    static let isSetup = "isSetup"
    static let refreshOnStart = "refreshOnStart"
    static let selectedPrice = "selectedPrice"
    static let selectedMensa = "selectedMensa"
    static let lastUpdate = "lastUpdate"
    static let jsonData = "jsonData"
}

struct Shortcuts {
    static let showToday = "de.marc-hein.mensaplan.showToday"
    static let showTomorrow = "de.marc-hein.mensaplan.showTomorrow"

}

enum DayValue {
    case TODAY
    case TOMORROW
}
