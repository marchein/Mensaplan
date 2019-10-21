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

struct MensaplanApp {
    static let appStoreId = "1484281036"
    static let mailAdress = "dev@marc-hein.de"
    static let website = "https://marc-hein.de/"
    static let versionString = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
    static let buildNumber = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
}
