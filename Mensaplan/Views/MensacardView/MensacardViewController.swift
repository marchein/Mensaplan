//
//  MensacardViewController.swift
//  Mensaplan
//
//  Created by Marc Hein on 05.05.21.
//  Copyright © 2021 Marc Hein. All rights reserved.
//

import UIKit
import Charts
import Toast

class MensacardViewController: UITableViewController {
    
    
    @IBOutlet weak var mensacardView: UIView!
    @IBOutlet weak var currentBalanceLabel: UILabel!
    @IBOutlet weak var historyChart: LineChartView!
    
    let mensaDB = MensaDatabase()
    let hapticsGenerator = UINotificationFeedbackGenerator()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if MensaplanApp.demo {
            setupDemoData()
        }
        
        styleMensacard()
        setupMensacard()
        setupChart()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupMensacard()
        setupChart()
    }
    
    func setupDemoData() {
        if mensaDB.getEntries().count == 0 {
            mensaDB.insertRecord(
                balance: 19.56,
                lastTransaction: 2.85,
                date: Date.getCurrentDate(),
                cardID: "1234567890"
            )
        }
    }
    
    func styleMensacard() {
        let gradient = CAGradientLayer()
        gradient.frame = mensacardView.bounds
        gradient.colors = [UIColor.white.cgColor, UIColor(red: 143/255, green: 214/255, blue: 189/255, alpha: 1.0).cgColor]
        
        mensacardView.clipsToBounds = true
        mensacardView.layer.insertSublayer(gradient, at: 0)
    }
    
    func setupMensacard() {
        let data: [HistoryItem] = mensaDB.getEntries()
        
        if data.count > 0 {
            currentBalanceLabel.text = data[0].getFormattedBalance()
        } else {
            currentBalanceLabel.text = "Noch nicht eingelesen..."
        }
    }
    
    func setupChart() {
        var dataEntries: [ChartDataEntry] = []
        var mensaEntries = mensaDB.getEntries()
        
        historyChart.clear()
        historyChart.noDataText = "Es wurden bisher keine Daten eingelesen..."
        
        if mensaEntries.count > 0 {
            mensaEntries.reverse()
            var lower = 0
            var upper = mensaEntries.count
            if mensaEntries.count > 20 {
                lower = mensaEntries.count - 20
                upper = mensaEntries.count
            }
            
            for i in lower..<upper {
                let dataEntry = ChartDataEntry(x: Double(i), y: mensaEntries[i].balance)
                dataEntries.append(dataEntry)
            }
            
            setChartData(dataEntries)
            
            
            historyChart.tintColor = .systemBlue
            
            let yAxis = historyChart.leftAxis
            yAxis.labelPosition = .outsideChart
            let valFormatter = NumberFormatter()
            valFormatter.numberStyle = .currency
            valFormatter.maximumFractionDigits = 2
            valFormatter.currencySymbol = "€"
            
            historyChart.leftAxis.valueFormatter = DefaultAxisValueFormatter(formatter: valFormatter)
            historyChart.rightAxis.enabled = false
            
            let xAxis = historyChart.xAxis
            xAxis.labelPosition = .bottom
            xAxis.setLabelCount(mensaEntries.count, force: true)
            historyChart.isUserInteractionEnabled = false
            
            xAxis.setLabelCount(4, force: true)
        }
    }
    
    func setChartData(_ dataEntries: [ChartDataEntry]) {
        let lineChartDataSet = LineChartDataSet(entries: dataEntries, label: "Guthaben")
        
        lineChartDataSet.mode = .cubicBezier
        
        lineChartDataSet.setColor(.systemBlue)
        lineChartDataSet.fillColor = .systemBlue
        lineChartDataSet.fillAlpha = 0.1
        lineChartDataSet.drawFilledEnabled = true
        
        lineChartDataSet.drawCircleHoleEnabled = false
        lineChartDataSet.circleRadius = 3
        lineChartDataSet.setCircleColor(.systemBlue)
        
        let lineChartData = LineChartData(dataSet: lineChartDataSet)
        lineChartData.setDrawValues(false)
        historyChart.data = lineChartData
        
    }
    
    @IBAction func mensacardTapped(_ sender: Any) {
        self.view.hideAllToasts()
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        if mensaDB.getEntries().count > 0 {
            let entry = mensaDB.getEntries()[0]
            self.mensacardView.makeToast("Einlesedatum: \(entry.getDateString(short: true))\nAktuelles Guthaben: \(entry.getFormattedBalance())\nLetzte Transaktion: \(entry.getFormattedLastTransaction())\nKarte Nr.: \(entry.cardID)", duration: 3.0, position: .center)
        } else {
            self.mensacardView.makeToast("Die Mensakarte wurde bisher noch nicht eingescannt.", duration: 3.0, position: .center)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 2, indexPath.row == 1 {
            performSegue(withIdentifier: "showHistorySegue", sender: self)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        styleMensacard()
    }
}
