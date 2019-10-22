//
//  SettingsTableViewController.swift
//  Mensaplan
//
//  Created by Marc Hein on 21.10.19.
//  Copyright © 2019 Marc Hein. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
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
    
    var isPickerHidden = true
    var selectedMensa : String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mensaPicker.delegate = self
        mensaPicker.dataSource = self

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        setupView()
    }
    
    func setupView() {
        let isSetup  = MensaplanApp.sharedDefaults.bool(forKey: LocalKeys.isSetup)
        if isSetup {
            refreshOnStartToggle.isOn = MensaplanApp.sharedDefaults.bool(forKey: LocalKeys.refreshOnStart)
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
        navigationController?.navigationBar.prefersLargeTitles = true
        if #available(iOS 13.0, *) {
            navigationController?.isModalInPresentation = true
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
        MensaplanApp.sharedDefaults.set(selectedMensa, forKey: LocalKeys.selectedMensa)
    }
    
    @IBAction func setRefreshOnStart(_ sender: Any) {
        MensaplanApp.sharedDefaults.set(refreshOnStartToggle.isOn, forKey: LocalKeys.refreshOnStart)
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
