//
//  Model.swift
//  Mensaplan
//
//  Created by Marc Hein on 21.10.19.
//  Copyright © 2019 Marc Hein. All rights reserved.
//

import Foundation

//MARK:- Local Keys
struct LocalKeys {
    static let isSetup = "isSetup"
    static let refreshOnStart = "refreshOnStart"
    static let selectedPrice = "selectedPrice"
    static let selectedMensa = "selectedMensa"
    static let lastUpdate = "lastUpdate"
    static let jsonData = "jsonData"
    static let showSideDish = "showSideDish"
    static let hasTipped = "hasTipped"
}


//MARK:- Shortcuts
struct Shortcuts {
    static let showToday = "de.marc-hein.mensaplan.showToday"
    static let showTomorrow = "de.marc-hein.mensaplan.showTomorrow"

}

//MARK:- DayValue
enum DayValue {
    case TODAY
    case TOMORROW
}

//MARK:- App Data
struct MensaplanApp {
    static let standorteValues = ["Mensa Tarforst", "Bistro A/B", "Mensa Petrisberg", "Mensa Schneidershof", "Mensa Irminenfreihof" ,"forU"]
    static let standorteKeys = ["standort-1","standort-2","standort-3","standort-4","standort-5","standort-7"]
    static let standorteOpenings: [Opening] = [
        Opening(semester: "1. Untergeschoss:\nMo.-Do. 11.15 Uhr bis 13.45 Uhr\nFr. 11.15 Uhr bis 13.30 Uhr\n\n2. Untergeschoss:\nMo.-Do. 11.15 Uhr bis 14.15 Uhr", semesterFerien: "Mo.-Fr. 11.30 Uhr bis 13.30 Uhr"),
        Opening(semester: "Mo.-Do. 07.45 Uhr bis 19.30 Uhr\nFr. 07.45 Uhr bis 16.30 Uhr\nSa. 08.45 Uhr bis 13.30 Uhr\n\nAbendmensa: Mo.-Do. 17.30 Uhr bis 19.00 Uhr\n\nSamstagsmensa: 11.30 Uhr bis 13.30 Uhr\n\nPASTA-THEKE: Mo.-Do. 11.30 Uhr bis 14.30 Uhr\nFreitag 11.30 Uhr bis 14.00 Uhr ", semesterFerien: "Mo.-Fr. 08.30 Uhr bis 16.30 Uhr\n\nPASTA-THEKE: Mo.-Do. 11.30 Uhr bis 14.30 Uhr\nFreitag 11.30 Uhr bis 14.00 Uhr"),
        Opening(semester: "Mo.-Do. 11.30 Uhr bis 13.45 Uhr\nFr. 11.30 Uhr bis 13.30 Uhr", semesterFerien: "Mo.-Fr. 11.30 Uhr bis 13.30 Uhr"),
        Opening(semester: "Mo.-Do. 11.15 Uhr bis 13.45 Uhr\nFr. 11.15 Uhr bis 13.30 Uhr", semesterFerien: "Mo.-Fr. 11.30 Uhr bis 13.30 Uhr"),
        Opening(semester: "Mo.-Do. 11.30 Uhr bis 13.45 Uhr\nFr. 11.30 Uhr bis 13.30 Uhr", semesterFerien: "In den Semesterferien ist die Mensa am Irminenfreihof geschlossen."),
        Opening(semester: "Mo.-Do. 08.00 Uhr bis 16.15 Uhr\nFr. 08.00 Uhr bis 14.45 Uhr", semesterFerien: "Mo.-Do. 08.00 Uhr bis 15.30 Uhr\nFr. 08.00 Uhr bis 14.45 Uhr")
    ]
    static let priceValues = ["student", "worker", "guest"]
    
    //MARK:- API Data
    static let STUDIWERK_URL = "https://www.studiwerk.de";
    static let API = "https://www.studiwerk.de/export/speiseplan.xml"
    static let NOODLE_COUNTER = "CASA BLANCA"
    static let MAIN_DISH_MINIMAL_PRICE: Double = 1.15
    
    static let groupIdentifier = "group.de.marc-hein.Mensaplan.Data"
    #if targetEnvironment(macCatalyst)
    static let appStoreId = "1484515269"
    #else
    static let appStoreId = "1484281036"
    #endif
    static let mailAdress = "dev@marc-hein.de"
    static let website = "https://marc-hein.de/"
    static let versionString = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
    static let buildNumber = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
    
    static let askForReviewAt = 5

    static let sharedDefaults: UserDefaults = UserDefaults(suiteName: MensaplanApp.groupIdentifier)!
    
    // MARK:- NFC Data
    static let demo: Bool = true
    static let APP_ID: Int = 0x5F8415
    static let FILE_ID: UInt8  = 1
    
    #if targetEnvironment(macCatalyst)
        static let canScan = false
    #else
        static let canScan = NFCTagReaderSession.readingAvailable || MensaplanApp.demo
    #endif

}

//MARK:- MensaplanIAP
struct MensaplanIAP {
    static let prefix = "maccatalyst."
    static let smallTip = "de.marc_hein.mensaplan.tip.sm"
    static let mediumTip = "de.marc_hein.mensaplan.tip.md"
    static let largeTip = "de.marc_hein.mensaplan.tip.lg"
    
    #if targetEnvironment(macCatalyst)
    static let allTips = [MensaplanIAP.prefix + MensaplanIAP.smallTip, MensaplanIAP.prefix + MensaplanIAP.mediumTip, MensaplanIAP.prefix + MensaplanIAP.largeTip]
    #else
    static let allTips = [MensaplanIAP.smallTip, MensaplanIAP.mediumTip, MensaplanIAP.largeTip]
    #endif
}

class Opening {
    var semester: String
    var semesterFerien: String
    
    init(semester: String, semesterFerien: String) {
        self.semester = semester
        self.semesterFerien = semesterFerien
    }
}
