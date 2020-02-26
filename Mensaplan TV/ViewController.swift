//
//  ViewController.swift
//  Mensaplan TV
//
//  Created by Marc Hein on 26.02.20.
//  Copyright © 2020 Marc Hein. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var mensaXML: MensaXML?
    var mensaData: Mensaplan?

    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        mensaXML = MensaXML(url: URL(string: MensaplanApp.API)!)
        mensaXML?.loadXML(onDone: { (mensaPlanData) in
            print(mensaPlanData)
            MensaplanApp.sharedDefaults.set(mensaPlanData, forKey: LocalKeys.jsonData)
            self.loadJSONintoUI(data: mensaPlanData, local: false)
            MensaplanApp.sharedDefaults.set(Date.getCurrentDate(), forKey: LocalKeys.lastUpdate)
        })
        // Do any additional setup after loading the view.
    }

    func loadJSONintoUI(data: Data, local: Bool) {
        self.mensaData = try? JSONDecoder().decode(Mensaplan.self, from: data)
        
        DispatchQueue.main.async {
            print("ViewController.swift - loadJSONintoUI() - Successfully used \(local ? "local" : "remote") JSON in UI")
            print(self.mensaData)
            self.tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let mensaData = mensaData {
            return mensaData.plan.count
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "locationCell", for: indexPath)
        print(indexPath.row)
        if let data = self.mensaData {
            cell.textLabel?.text = data.plan[indexPath.row].day[0].title
        } else {
            cell.textLabel?.text = "Test"
        }
        return cell
    }

}

