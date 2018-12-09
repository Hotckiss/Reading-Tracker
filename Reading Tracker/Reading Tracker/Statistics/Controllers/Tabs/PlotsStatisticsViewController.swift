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
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        let barChart = BarChartView(forAutoLayout: ())
        view.addSubview(barChart)
        barChart.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 16, left: 0, bottom: 0, right: 0))
        barChart.autoSetDimension(.height, toSize: 400)
        
        var arr: [BarChartDataEntry] = []
        for i in 1...30 {
            arr.append(BarChartDataEntry(x: Double(i), y: Double(sin(Double(i)) * 10)))
        }
        let dataSet = BarChartDataSet(values: arr, label: "Widgets Type")
        let data = BarChartData(dataSets: [dataSet])
        barChart.data = data
        barChart.chartDescription?.text = "Number of Widgets by Type"
        
        barChart.notifyDataSetChanged()
    }
}
