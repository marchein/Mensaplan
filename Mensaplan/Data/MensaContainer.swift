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
    var mensaXML: MensaXML?
    var mensaData: Mensaplan?
    var tempMensaData: MensaplanDay?
    
    init(mainVC: MainTableViewController) {
        self.navigationController = MensaplanApp.getMainVC()?.parent as? UINavigationController
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
            MensaplanApp.sharedDefaults.set(mensaPlanData, forKey: LocalKeys.mensaplanJSONData)
            self.loadJSONintoUI(mensaPlanData: mensaPlanData, local: false)
            MensaplanApp.sharedDefaults.set(Date.getCurrentDate(), forKey: LocalKeys.lastUpdate)
        })
    }

    func loadJSONintoUI(mensaPlanData: Data, local: Bool) {
        let unsortedMensaPlan = try? JSONDecoder().decode(Mensaplan.self, from: mensaPlanData)
        self.mensaData = unsortedMensaPlan?.getSortedPlan()
        
        DispatchQueue.main.async {
            print("MensaData.swift - loadJSONintoUI() - Successfully used \(local ? "local" : "remote") JSON in UI")
            if let mainVC = MensaplanApp.getMainVC() {
                mainVC.showEmptyView()
                self.navigationController?.view.hideToastActivity()
                mainVC.refreshControl?.endRefreshing()
                mainVC.tableView.reloadData()
            }
        }
    }
}
