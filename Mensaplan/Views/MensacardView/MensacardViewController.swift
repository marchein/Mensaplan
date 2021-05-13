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
    
    /// Get access to the database which stores mensacard entries
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
        let endColor = getColorByEuro(euroValue: currentBalance ?? -1)
        
        gradientLayer.frame = mensacardView.bounds
        gradientLayer.locations = [0.25, 1.5]
        mensacardView.clipsToBounds = true
        mensacardView.layer.insertSublayer(gradientLayer, at: 0)
        
        DispatchQueue.main.async() {
            self.gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
        }
    }
    
    /// This function returns a corresponding color for a given `euroValue`.
    ///
    /// ```
    /// getColorByEuro(euroValue: 7.44) // UIColor.systenYellow
    /// ```
    ///
    /// - Warning: If `euroValue` is not given or negative UIColor.lightGray is returned
    /// - Parameter euroValue: The value which should be represented by a color
    /// - Returns: A color corresponding to `euroValue`.
    func getColorByEuro(euroValue: Double) -> UIColor {
        switch euroValue {
        case _ where euroValue >= 10:
            return .systemGreen
        case _ where euroValue >= 5:
            return .systemYellow
        case _ where euroValue >= 3:
            return .systemOrange
        case _ where euroValue >= 0:
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
        historyChart.clear()
        historyChart.noDataText = "Es wurden bisher keine Daten eingelesen..."
        historyChart.noDataTextColor = .secondaryLabel
        historyChart.legend.enabled = false
        
        var mensaEntries = mensaDB.getEntries()
        if mensaEntries.count > 0 {
            mensaEntries.reverse()
            var lower = 0
            var upper = mensaEntries.count
            let NUMBER_OF_ENTRIES_IN_CHART = 6
            if mensaEntries.count > NUMBER_OF_ENTRIES_IN_CHART {
                lower = mensaEntries.count - NUMBER_OF_ENTRIES_IN_CHART
                upper = mensaEntries.count
            }
            
            var lastNMensaEntries = [HistoryItem]()
            for i in lower..<upper {
                lastNMensaEntries.append(mensaEntries[i])
            }
            
            // Thanks to https://stackoverflow.com/questions/41720445/ios-charts-3-0-align-x-labels-dates-with-plots
            // (objects is defined as an array of struct with date and value)

            // Define the reference time interval
            var referenceTimeInterval: TimeInterval = 0
            if let minTimeInterval = (lastNMensaEntries.map { $0.getDate()?.timeIntervalSince1970 ?? 0 }).min() {
                referenceTimeInterval = minTimeInterval
            }

            // Define chart xValues formatter
            let template = "dd.MM."
            let format = DateFormatter.dateFormat(fromTemplate: template, options: 0, locale: NSLocale.current)
            let formatter = DateFormatter()
            formatter.dateFormat = format

            let xValuesNumberFormatter = ChartXAxisFormatter(referenceTimeInterval: referenceTimeInterval, dateFormatter: formatter)

            // Define chart entries
            var entries = [ChartDataEntry]()
            for object in lastNMensaEntries {
                let timeInterval = object.getDate()?.timeIntervalSince1970 ?? 0
                let xValue = (timeInterval - referenceTimeInterval) / (3600 * 24)

                let yValue = object.balance
                let entry = ChartDataEntry(x: xValue, y: yValue)
                entries.append(entry)
            }

            // Pass these entries and the formatter to the Chart ...
            setChartData(entries)
            
            historyChart.tintColor = .systemBlue
            
            let yAxis = historyChart.leftAxis
            yAxis.labelPosition = .outsideChart
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = .currency
            numberFormatter.maximumFractionDigits = 2
            numberFormatter.currencySymbol = "€"
            
            historyChart.leftAxis.valueFormatter = DefaultAxisValueFormatter(formatter: numberFormatter)
            historyChart.rightAxis.enabled = false
            
            let xAxis = historyChart.xAxis
            xAxis.labelPosition = .bottom
//            xAxis.avoidFirstLastClippingEnabled = true
            xAxis.valueFormatter = xValuesNumberFormatter
            
            historyChart.isUserInteractionEnabled = false
            
            showHistoryCell.textLabel?.textColor = .label
            showHistoryCell.selectionStyle = .default
        } else {
            showHistoryCell.textLabel?.textColor = .secondaryLabel
            showHistoryCell.selectionStyle = .none
        }
    }
    
    func setChartData(_ dataEntries: [ChartDataEntry]) {
        let lineChartDataSet = LineChartDataSet(entries: dataEntries, label: "Guthaben")
                
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
}
