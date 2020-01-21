//
//  SettingsTableViewController.swift
//  Mensaplan
//
//  Created by Marc Hein on 21.10.19.
//  Copyright © 2019 Marc Hein. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController, UIPickerViewDataSource, UIPickerViewDelegate,UIAdaptivePresentationControllerDelegate {
    
    @IBOutlet weak var refreshOnStartToggle: UISwitch!
    @IBOutlet weak var priceSelector: UIView!
    @IBOutlet weak var selectedMensaName: UILabel!
    @IBOutlet weak var mensaPicker: UIPickerView!
    @IBOutlet weak var mensaNameCell: UITableViewCell!
    @IBOutlet weak var mensaPickerCell: UITableViewCell!
    @IBOutlet weak var pricePicker: UISegmentedControl!
    @IBOutlet weak var appVersionCell: UITableViewCell!
    @IBOutlet weak var appSupportCell: UITableViewCell!
    @IBOutlet weak var appStoreCell: UITableViewCell!
    @IBOutlet weak var rateAppCell: UITableViewCell!
    @IBOutlet weak var developerCell: UITableViewCell!
    @IBOutlet weak var showSideDishToggle: UISwitch!
    
    var isPickerHidden = true
    var selectedMensa : String!
    var madeChanges = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mensaPicker.delegate = self
        mensaPicker.dataSource = self

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        setupView()
        
        self.navigationController?.presentationController?.delegate = self
    }
    
    func setupView() {
        let isSetup  = MensaplanApp.sharedDefaults.bool(forKey: LocalKeys.isSetup)
        if isSetup {
            refreshOnStartToggle.isOn = MensaplanApp.sharedDefaults.bool(forKey: LocalKeys.refreshOnStart)
            showSideDishToggle.isOn = MensaplanApp.sharedDefaults.bool(forKey: LocalKeys.showSideDish)
            guard let selectedPrice = MensaplanApp.sharedDefaults.string(forKey: LocalKeys.selectedPrice) else {
                return
            }
            pricePicker.selectedSegmentIndex = MensaplanApp.priceValues.firstIndex(of: selectedPrice)!
            let selectedMensaValue = MensaplanApp.sharedDefaults.string(forKey: LocalKeys.selectedMensa)!
            let selectedMensaValueIndex = MensaplanApp.standorteKeys.firstIndex(of: selectedMensaValue)!
            selectedMensaName.text = MensaplanApp.standorteValues[selectedMensaValueIndex]
            mensaPicker.selectRow(selectedMensaValueIndex, inComponent: 0, animated: false)
            appVersionCell.detailTextLabel?.text = MensaplanApp.versionString
        }

        if #available(iOS 13.0, *) {
            //navigationController?.isModalInPresentation = true
        }
        
    }
    
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        if let navVC = UIApplication.shared.windows.first!.rootViewController as? UINavigationController, let mainVC = navVC.viewControllers[0] as? MainTableViewController {
            mainVC.refreshAction(presentationController)
        }
    }
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return MensaplanApp.standorteKeys.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return MensaplanApp.standorteValues[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedMensa = MensaplanApp.standorteKeys[row]
        selectedMensaName.text = MensaplanApp.standorteValues[row]
        if selectedMensa != MensaplanApp.sharedDefaults.string(forKey: LocalKeys.selectedMensa) {
            MensaplanApp.sharedDefaults.set(selectedMensa, forKey: LocalKeys.selectedMensa)
            madeChanges = true
        }
    }
    
    @IBAction func setRefreshOnStart(_ sender: Any) {
        MensaplanApp.sharedDefaults.set(refreshOnStartToggle.isOn, forKey: LocalKeys.refreshOnStart)
    }
    
    @IBAction func setShowSideDish(_ sender: Any) {
        MensaplanApp.sharedDefaults.set(showSideDishToggle.isOn, forKey: LocalKeys.showSideDish)
    }
    
    @IBAction func priceSelection(_ sender: Any) {
        let selectedIndex = pricePicker.selectedSegmentIndex
        let priceValue = MensaplanApp.priceValues[selectedIndex]
        MensaplanApp.sharedDefaults.set(priceValue, forKey: LocalKeys.selectedPrice)
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
