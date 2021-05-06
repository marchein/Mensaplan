//
//  Model.swift
//  Mensaplan
//
//  Created by Marc Hein on 21.10.19.
//  Copyright © 2019 Marc Hein. All rights reserved.
//

import Foundation
import CoreNFC

//MARK:- Local Keys
struct LocalKeys {
    static let isSetup = "isSetup"
    static let refreshOnStart = "refreshOnStart"
    static let selectedPrice = "selectedPrice"
    static let selectedMensa = "selectedMensa"
    static let lastUpdate = "lastUpdate"
    static let mensaplanJSONData = "mensaplanJSONData"
    static let showSideDish = "showSideDish"
}


//MARK:- Shortcuts
struct Shortcuts {
    static let showToday = "de.hochschule-trier.mensa.showToday"
    static let showTomorrow = "de.hochschule-trier.mensa.showTomorrow"
    
}

//MARK:- DayValue
enum DayValue {
    case TODAY
    case TOMORROW
}

//MARK:- App Data
struct MensaplanApp {
    static let standorteValues = ["Mensa Tarforst", "Bistro A/B", "Mensa Petrisberg", "Mensa Schneidershof", "Mensa Irminenfreihof", "forU"]
    static let standorteKeys = ["standort-1","standort-2","standort-3","standort-4","standort-5", "standort-7"]
    static let priceValues = ["student", "worker", "guest"]
    
    //MARK:- API Data
    static let STUDIWERK_URL = "https://www.studiwerk.de";
    static let API = "https://www.studiwerk.de/export/speiseplan.xml"
    static let OPENINGS_URL = "https://www.studiwerk.de/cms/standorte_und_oeffnungszeiten-1001.html"
    static let NOODLE_COUNTER = "CASA BLANCA"
    static let MAIN_DISH_MINIMAL_PRICE: Double = 1.15
    
    static let groupIdentifier = "group.de.hochschule-trier.mensa.Data"
    static let appStoreId = "1535338070"
    static let mailAdress = "M.Hein@hochschule-trier.de"
    static let website = "https://marc-hein.de/"
    static let versionString = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
    static let buildNumber = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
    
    static let askForReviewAt = 5
    
    static let sharedDefaults = UserDefaults(suiteName: MensaplanApp.groupIdentifier)!
    
    static let imageCache = NSCache<AnyObject, AnyObject>()
    
    
    // MARK:- NFC Data
    static let demo: Bool = true
    static let APP_ID: Int = 0x5F8415
    static let FILE_ID: UInt8  = 1
    
    #if targetEnvironment(macCatalyst)
    static let canScan = false
    #elseif targetEnvironment(simulator)
    static let canScan = MensaplanApp.demo
    #else
    static let canScan = appCanScan()
    #endif
    
    static func appCanScan() -> Bool {
        return NFCTagReaderSession.readingAvailable || MensaplanApp.demo
    }
}

//MARK:- Segues
struct MensaplanSegue {
    static let emptyDetail = "emptyDetail"
    static let showDetail = "showDetail"
    static let manualShowDetail = "manualShowDetail"
    static let showSettings = "settingsSegue"
    
}

class Opening {
    var semester: String
    var semesterFerien: String
    
    init(semester: String, semesterFerien: String) {
        self.semester = semester
        self.semesterFerien = semesterFerien
    }
}
