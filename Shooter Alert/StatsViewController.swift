//
//  StatsViewController.swift
//  Shooter Alert
//
//  Created by Akira on 7/4/17.
//  Copyright © 2017 mypc. All rights reserved.
//

import UIKit
import Charts

class StatsViewController: UIViewController, IAxisValueFormatter, IValueFormatter {

    @IBOutlet weak var barChartView: BarChartView!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    var months: [String]! = ["", "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        barChartView.chartDescription?.enabled = false
        barChartView.maxVisibleCount = 40
        barChartView.drawGridBackgroundEnabled = false
        barChartView.drawBarShadowEnabled = false;
        
        barChartView.drawValueAboveBarEnabled = false
        barChartView.highlightFullBarEnabled = false;
        barChartView.pinchZoomEnabled = false
        
        barChartView.leftAxis.enabled = false
        barChartView.rightAxis.enabled = false;
     
        let l = barChartView.legend
        l.wordWrapEnabled = true
        l.verticalAlignment = .bottom
        l.horizontalAlignment = .left
        l.orientation = .horizontal
        l.drawInside = false
        
        let xAxis = barChartView.xAxis
        xAxis.labelPosition = .bottom
        xAxis.axisMinimum = 0
        xAxis.granularity = 1
        xAxis.labelCount = 12
        xAxis.valueFormatter = self
        xAxis.labelFont = .systemFont(ofSize: 18)
        xAxis.labelTextColor = UIColor.darkGray
        
        barChartView.leftAxis.drawGridLinesEnabled = false
        barChartView.xAxis.drawGridLinesEnabled = false
    }
    
    func setChart() {
        
        let date = Date()
        let calendar = Calendar.current
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        
        var dataEntries: [BarChartDataEntry] = []
        var total_count: Int = 0;
        
        for i in 0..<month+1 {
            var val1 = AppManager.sharedInstance.getCounts(year: year, month: i, killed: true)
            var val2 = AppManager.sharedInstance.getCounts(year: year, month: i, killed: false)
            if i == 0 {
                val1 = 0
                val2 = 0
            }
            total_count += val1
            total_count += val2
            let dataEntry = BarChartDataEntry(x: Double(i), yValues: [Double(val1), Double(val2)])
            dataEntries.append(dataEntry)
        }

        let chartDataSet: BarChartDataSet
        
        if barChartView.data != nil && (barChartView.data?.dataSetCount)! > 0 {
            chartDataSet = barChartView.data?.getDataSetByIndex(0) as! BarChartDataSet
            chartDataSet.values = dataEntries
            barChartView.data?.notifyDataChanged()
            barChartView.notifyDataSetChanged()
        }
        else {
            chartDataSet = BarChartDataSet(values: dataEntries, label: "")
            chartDataSet.stackLabels = ["Fatalities", "Injured"]
            chartDataSet.colors = [KColorBasic, KColorGrey]
            let chartData = BarChartData(dataSet: chartDataSet)
            chartData.setValueTextColor(UIColor.white)
            chartData.setValueFont(.systemFont(ofSize: 14))
            chartData.setValueFormatter(self)
            barChartView.data = chartData
        }
        barChartView.legend.enabled = false
        
        descriptionLabel.text = String.init(format: "U.S. mass shootings in %d", year)
        countLabel.text = String.init(format: "%d", total_count)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setChart()
    }
    
    func stringForValue(_ value: Double,
                        axis: AxisBase?) -> String {
        return months[Int(value) % months.count]
    }
    
    func stringForValue(_ value: Double,
                        entry: ChartDataEntry,
                        dataSetIndex: Int,
                        viewPortHandler: ViewPortHandler?) -> String{
        if value == 0 { return "" }
        
        return String.init(format: "%d", Int(value))
    }
}
