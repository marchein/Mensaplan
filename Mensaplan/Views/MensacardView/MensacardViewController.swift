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
    
    @IBOutlet weak var mensacardCell: UITableViewCell!
    @IBOutlet weak var mensacardView: UIView!
    @IBOutlet weak var currentBalanceLabel: UILabel!
    @IBOutlet weak var historyChart: LineChartView!
    @IBOutlet weak var showHistoryCell: UITableViewCell!
    
    let mensaDB = MensaDatabase()
    let hapticsGenerator = UINotificationFeedbackGenerator()
    let gradientLayer = CAGradientLayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        styleMensacard()
        setMensacardData()
        setupChart()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setMensacardData()
        setupChart()
    }
    
    func styleMensacard(currentBalance: Double? = -1) {
        mensacardCell.layer.borderWidth = 1
        mensacardCell.layer.borderColor = UIColor.label.cgColor
        let startColor = UIColor.white
        let endColor = getColorByEuro(euro: currentBalance ?? -1)
        
        gradientLayer.frame = mensacardView.bounds
        gradientLayer.locations = [0.25, 1.5]
        mensacardView.clipsToBounds = true
        mensacardView.layer.insertSublayer(gradientLayer, at: 0)
        
        DispatchQueue.main.async() {
            self.gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
        }
    }
    
    func getColorByEuro(euro: Double) -> UIColor {
        switch euro {
        case _ where euro >= 10:
            return .systemGreen
        case _ where euro >= 5:
            return .systemYellow
        case _ where euro >= 3:
            return .systemOrange
        case _ where euro >= 0:
            return .red
        default:
            return .lightGray
        }
    }
    
    func setMensacardData() {
        let data: [HistoryItem] = mensaDB.getEntries()
        
        if data.count > 0 {
            currentBalanceLabel.text = data[0].getFormattedBalance()
        } else {
            currentBalanceLabel.text = "Noch nicht eingelesen..."
        }
        
        if let firstEntry = data.first {
            styleMensacard(currentBalance: firstEntry.balance)
        } else {
            styleMensacard()
        }
    }
    
    func setupChart() {
        var dataEntries: [ChartDataEntry] = []
        var mensaEntries = mensaDB.getEntries()
        
        historyChart.clear()
        historyChart.noDataText = "Es wurden bisher keine Daten eingelesen..."
        historyChart.noDataTextColor = .secondaryLabel
        
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
            showHistoryCell.textLabel?.textColor = .label
            showHistoryCell.selectionStyle = .default
        } else {
            showHistoryCell.textLabel?.textColor = .secondaryLabel
            showHistoryCell.selectionStyle = .none
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
            if mensaDB.getEntries().count > 0 {
                performSegue(withIdentifier: "showHistorySegue", sender: self)
            } else {
                self.historyChart.makeToast("Es wurden bisher noch keine Daten in den Verlauf eingefügt... Scanne Deine Mensakarte über den Button \"Einlesen\".", duration: 3.0, position: .center)
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = mensacardView.bounds
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        tableView.reloadData()
        setMensacardData()
    }
    
    @IBAction func longPress(_ sender: Any) {
        if let gestureReconizer = sender as? UILongPressGestureRecognizer {
            gestureReconizer.minimumPressDuration = 3.0
            print(MensaplanApp.devMode)
            if !MensaplanApp.devMode {
                if gestureReconizer.state != UIGestureRecognizer.State.ended {
                    historyChart.makeToast("Development mode is about to be enabled...", duration: 1.0, position: .center)
                } else {
                    MensaplanApp.devMode = true
                    historyChart.makeToast("Enabled development mode!", duration: 1.0, position: .center)
                }
            }
        }
    }
}
