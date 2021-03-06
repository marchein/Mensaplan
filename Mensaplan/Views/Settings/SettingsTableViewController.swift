//
//  SettingsTableViewController.swift
//  Mensaplan
//
//  Created by Marc Hein on 21.10.19.
//  Copyright © 2019 Marc Hein. All rights reserved.
//

import UIKit
import HeinHelpers

class SettingsTableViewController: UITableViewController, UIAdaptivePresentationControllerDelegate {
    
    @IBOutlet weak var refreshOnStartCell: UITableViewCell!
    @IBOutlet weak var refreshOnStartToggle: UISwitch!
    @IBOutlet weak var priceSelector: UIView!
    @IBOutlet weak var selectedMensaName: UILabel!
    @IBOutlet weak var selectedTabName: UILabel!
    @IBOutlet weak var mensaNameCell: UITableViewCell!
    @IBOutlet weak var pricePicker: UISegmentedControl!
    @IBOutlet weak var appVersionCell: UITableViewCell!
    @IBOutlet weak var appSupportCell: UITableViewCell!
    @IBOutlet weak var appStoreCell: UITableViewCell!
    @IBOutlet weak var rateAppCell: UITableViewCell!
    @IBOutlet weak var developerCell: UITableViewCell!
    @IBOutlet weak var showSideDishToggle: UISwitch!
    @IBOutlet weak var closeButton: UIBarButtonItem!
    
    var selectedMensa : String!
    //MARK: - Dev Mode
    @IBOutlet weak var disableDevModeCell: UITableViewCell!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        #if targetEnvironment(macCatalyst)
        closeButton.tintColor = .label
        #endif
        
        setupView()
        
        self.navigationController?.presentationController?.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        tableView.reloadData()
        self.updateCurrentMensa()
        #if !targetEnvironment(macCatalyst)
        self.updateCurrentTab()
        #endif
    }
    
    func setupView() {
        let isSetup  = MensaplanApp.userDefaults.bool(forKey: LocalKeys.isSetup)
        if isSetup {
            self.refreshOnStartToggle.isOn = MensaplanApp.userDefaults.bool(forKey: LocalKeys.refreshOnStart)
            self.showSideDishToggle.isOn = MensaplanApp.userDefaults.bool(forKey: LocalKeys.showSideDish)
            guard let selectedPrice = MensaplanApp.userDefaults.string(forKey: LocalKeys.selectedPrice) else {
                return
            }
            self.pricePicker.selectedSegmentIndex = MensaplanApp.priceValues.firstIndex(of: selectedPrice)!
            appVersionCell.detailTextLabel?.text = "\(MensaplanApp.versionString) (\(MensaplanApp.buildNumber))"
            self.updateCurrentMensa()
            #if !targetEnvironment(macCatalyst)
            self.updateCurrentTab()
            #endif
        }
        
        if MensaplanApp.canScan {
            self.navigationItem.rightBarButtonItem = nil
        }
    }
    
    func updateCurrentMensa() {
        self.mensaNameCell.detailTextLabel?.text = MensaplanApp.standorteValues[MensaplanApp.standorteKeys.firstIndex(of: MensaplanApp.userDefaults.string(forKey: LocalKeys.selectedMensa) ?? MensaplanApp.standorteKeys[0]) ?? 0]
    }
    
    #if !targetEnvironment(macCatalyst)
    func updateCurrentTab() {
        self.selectedTabName.text = MensaplanApp.tabValues[MensaplanApp.tabValues.firstIndex(of: MensaplanApp.userDefaults.string(forKey: LocalKeys.defaultTab) ?? MensaplanApp.tabValues[0]) ?? 0]
    }
    #endif
    
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        if let mainVC = MensaplanApp.getMainVC() {
            mainVC.refreshAction(presentationController)
        }
    }
    
    @IBAction func setRefreshOnStart(_ sender: Any) {
        MensaplanApp.userDefaults.set(refreshOnStartToggle.isOn, forKey: LocalKeys.refreshOnStart)
        #if targetEnvironment(macCatalyst)
        HeinHelpers.showMessage(title: "Aktualisieren beim Öffnen", message: refreshOnStartToggle.isOn ? "Die Daten werden nun beim Start automatisch aktualisiert" : "Die Daten werden nun beim Start nicht mehr automatisch aktualisiert", on: self)
        #endif
    }
    
    @IBAction func setShowSideDish(_ sender: Any) {
        MensaplanApp.userDefaults.set(showSideDishToggle.isOn, forKey: LocalKeys.showSideDish)
        #if targetEnvironment(macCatalyst)
        HeinHelpers.showMessage(title: "Beilagen anzeigen", message: showSideDishToggle.isOn ? "Die Beilagen werden nun angezeigt" : "Die Beilagen werden nun nicht mehr angezeigt", on: self)
        #endif
    }
    
    @IBAction func priceSelection(_ sender: Any) {
        let selectedIndex = pricePicker.selectedSegmentIndex
        let priceValue = MensaplanApp.priceValues[selectedIndex]
        MensaplanApp.userDefaults.set(priceValue, forKey: LocalKeys.selectedPrice)
    }
    
    @IBAction func doneAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        performSegue(withIdentifier: "unwindToMain", sender: sender)
    }
    
    func appStoreAction() {
        let urlStr = "itms-apps://itunes.apple.com/app/id\(MensaplanApp.appStoreId)"
        if let url = URL(string: urlStr), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
}
