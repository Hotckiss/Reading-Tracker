//
//  PlotsStatisticsViewController.swift
//  Reading Tracker
//
//  Created by Andrei Kirilenko on 01/12/2018.
//  Copyright © 2018 Andrei Kirilenko. All rights reserved.
//

import Foundation
import UIKit
import Charts

final class PlotsStatisticsViewController: UIViewController {
    private var readTimeBarChart: BarChartView!
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        let readTimeBarChart = BarChartView(forAutoLayout: ())
        view.addSubview(readTimeBarChart)
        readTimeBarChart.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 16, left: 0, bottom: 0, right: 0))
        readTimeBarChart.autoSetDimension(.height, toSize: 200)
        readTimeBarChart.animate(xAxisDuration: 0.5, yAxisDuration: 0.5, easingOption: .easeInExpo)
        readTimeBarChart.xAxis.drawGridLinesEnabled = false
        readTimeBarChart.rightAxis.enabled = false
        readTimeBarChart.chartDescription = nil
        readTimeBarChart.xAxis.labelPosition = .bottom
        readTimeBarChart.xAxis.granularity = 1
        /*let marker: BalloonMarker = BalloonMarker(color: UIColor.black, font: UIFont(name: "Helvetica", size: 12)!, textColor: UIColor.white, insets: UIEdgeInsets(top: 7.0, left: 7.0, bottom: 7.0, right: 7.0))
        marker.minimumSize = CGSize(width: 75.0, height: 35.0)
        readTimeBarChart.marker = marker*/
        self.readTimeBarChart = readTimeBarChart

        let months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
        let unitsSold = [20000.0, 4000.0, 6000.0, 3000.0, 10002.0, 10006.0, 4000.0, 18000.0, 2000.0, 4000.0, 5000.0, 4000.0]
        updateReadChart(dataPoints: months, values: unitsSold)
    }
    
    func updateReadChart(dataPoints: [String], values: [Double]) {
        readTimeBarChart.noDataText = "Нет данных."
        
        var dataEntries: [BarChartDataEntry] = []
        
        for i in 0..<dataPoints.count {
            let dataEntry = BarChartDataEntry(x: Double(i), y: values[i])//BarChartDataEntry(value: values[i], xIndex: i)
            dataEntries.append(dataEntry)
        }
        
        let chartDataSet = BarChartDataSet(values: dataEntries, label: "Время чтения в день")//BarChartDataSet(yVals: dataEntries, label: "Units Sold")
        chartDataSet.colors = [UIColor(rgb: 0xedaf97)]
        let chartData = BarChartData(dataSets: [chartDataSet])//BarChartData(xVals: months, dataSet: chartDataSet)
        readTimeBarChart.xAxis.valueFormatter = IndexAxisValueFormatter(values: dataPoints)
        readTimeBarChart.leftAxis.valueFormatter = ToHrsFormatter()
        readTimeBarChart.data = chartData
        readTimeBarChart.notifyDataSetChanged()
    }
    
    private class ToHrsFormatter: IAxisValueFormatter {
        func stringForValue(_ value: Double, axis: AxisBase?) -> String {
            let intSecs = Int(value)
            let mins = (intSecs / 60) % 60
            let hrs = intSecs / 3600
            return "\(hrs) ч \(mins) мин"
        }
    }
}
