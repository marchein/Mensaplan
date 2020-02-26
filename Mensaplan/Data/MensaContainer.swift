//
//  MensaData.swift
//  Mensaplan
//
//  Created by Marc Hein on 18.02.20.
//  Copyright © 2020 Marc Hein. All rights reserved.
//

import UIKit

class MensaContainer {
    var db = MensaDatabase()
    var navigationController: UINavigationController?
    var mainVC: MainTableViewController?
    var mensaXML: MensaXML?
    var mensaData: Mensaplan?
    var tempMensaData: MensaplanDay?
    
    init(mainVC: MainTableViewController) {
        self.mainVC = mainVC
        self.navigationController = mainVC.parent as? UINavigationController
        if MensaplanApp.sharedDefaults.bool(forKey: LocalKeys.refreshOnStart) {
            loadMensaData()
        }
    }
    
    init() {
        loadMensaData()
    }
    
    func loadMensaData() {
        mensaXML = MensaXML(url: URL(string: MensaplanApp.API)!)
        mensaXML?.loadXML(onDone: { (mensaPlanData: Data) in
            MensaplanApp.sharedDefaults.set(mensaPlanData, forKey: LocalKeys.jsonData)
            self.loadJSONintoUI(data: mensaPlanData, local: false)
            MensaplanApp.sharedDefaults.set(Date.getCurrentDate(), forKey: LocalKeys.lastUpdate)
        })
    }
    
    func loadJSONintoUI(data: Data, local: Bool) {
        self.mensaData = try? JSONDecoder().decode(Mensaplan.self, from: data)
        
        DispatchQueue.main.async {
            print("MensaData.swift - loadJSONintoUI() - Successfully used \(local ? "local" : "remote") JSON in UI")
            if let mainVC = self.mainVC {
                mainVC.showEmptyView()
                self.navigationController?.view.hideToastActivity()
                mainVC.refreshControl?.endRefreshing()
                mainVC.tableView.reloadData()
                #if !targetEnvironment(macCatalyst)
                mainVC.sendMessageToWatch()
                #endif
            }
        }
    }
}
