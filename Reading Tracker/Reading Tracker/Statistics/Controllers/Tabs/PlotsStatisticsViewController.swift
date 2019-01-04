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
    private var readTimeChart: LineChartView!
    private var pagesCountChart: LineChartView!
    private var sessionsCountChart: LineChartView!
    private var sessions: [UploadSessionModel] = []
    private var grouppedByDaySessions: [[UploadSessionModel]] = []
    private var grouppedByMonthSessions: [[UploadSessionModel]] = []
    private var booksMap: [String : BookModel] = [:]
    private var interval: StatsInterval = .allTime
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(sessions: [UploadSessionModel], booksMap: [String : BookModel], interval: StatsInterval) {
        self.interval = interval
        guard !sessions.isEmpty else {
            return
        }
        
        self.sessions = sessions
        self.booksMap = booksMap
        
        let groupedSessionsDay: [(UInt64, [UploadSessionModel])] = Dictionary(grouping: sessions) {
            let daysSince1970 = UInt64($0.startTime.timeIntervalSince1970) / 86400
            return daysSince1970
        }
        .sorted {
            $0.key > $1.key
        }
        
        grouppedByDaySessions = groupedSessionsDay.map { $0.1 }
        
        let groupedSessionsMonth: [(Int, [UploadSessionModel])] = Dictionary(grouping: sessions) {
            let cal = Calendar.current
            let year = cal.component(.year, from: $0.startTime)
            let month = cal.component(.month, from: $0.startTime)
            return year * 12 + month
            }
            .sorted {
                $0.key > $1.key
        }
        
        grouppedByMonthSessions = groupedSessionsMonth.map {
            $0.1
        }
        
        updateCharts(interval: interval)
    }
    
    private func updateCharts(interval: StatsInterval) {
        guard !sessions.isEmpty else {
            return
        }
        
        switch interval {
        case .allTime:
            let monthsMap = ["Янв", "Фев", "Мар", "Апр", "Май", "Июн", "Июл", "Авг", "Сен", "Окт", "Ноя", "Дек"]
            let currentDate = Date()
            let minDate = sessions.map({ $0.startTime }).min() ?? currentDate
            let minDateMonth = Calendar.current.component(.year, from: minDate) * 12 +
                Calendar.current.component(.month, from: minDate) - 1
            
            let currentDateMonth = Calendar.current.component(.year, from: currentDate) * 12 +
                Calendar.current.component(.month, from: currentDate) - 1
            
            let groupedSessionsMonth: [Int: [UploadSessionModel]] = Dictionary(grouping: sessions) {
                let cal = Calendar.current
                let year = cal.component(.year, from: $0.startTime)
                let month = cal.component(.month, from: $0.startTime)
                return year * 12 + (month - 1)
            }
            
            if readTimeChart != nil {
                var xLabels: [String] = []
                var yVals: [Double] = []
                
                for month in minDateMonth...currentDateMonth {
                    let label = monthsMap[month % 12] + ((month % 12 == 0) ? " \(month / 12)": "")
                    var val: Double = 0
                    for session in groupedSessionsMonth[month] ?? [] {
                        val += Double(session.time)
                    }
                    
                    xLabels.append(label)
                    yVals.append(val)
                }
                
                updateReadChart(dataPoints: xLabels, values: yVals)
            }
            
            if pagesCountChart != nil {
                var xLabels: [String] = []
                var yVals: [Double] = []
                
                for month in minDateMonth...currentDateMonth {
                    let label = monthsMap[month % 12] + ((month % 12 == 0) ? " \(month / 12)": "")
                    var val: Double = 0
                    for session in groupedSessionsMonth[month] ?? [] {
                        val += Double(abs(session.finishPage - session.startPage))
                    }
                    
                    xLabels.append(label)
                    yVals.append(val)
                }
                updatePagesChart(dataPoints: xLabels, values: yVals)
            }
            
            if sessionsCountChart != nil {
                var xLabels: [String] = []
                var yVals: [Double] = []
                
                for month in minDateMonth...currentDateMonth {
                    let label = monthsMap[month % 12] + ((month % 12 == 0) ? " \(month / 12)": "")
                    let val: Double = Double((groupedSessionsMonth[month] ?? []).count)
                    
                    xLabels.append(label)
                    yVals.append(val)
                }
                updateSessionsChart(dataPoints: xLabels, values: yVals)
            }
        case .lastYear:
            let months = ["Янв", "Фев", "Мар", "Апр", "Май", "Июн", "Июл", "Авг", "Сен", "Окт", "Ноя", "Дек"]
            let currentDate = Date()
            let cal = Calendar.current
            
            if readTimeChart != nil {
                var vals: [Double] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
                
                for sessionsInMonth in grouppedByMonthSessions {
                    guard !sessionsInMonth.isEmpty else {
                        continue
                    }
                    
                    if cal.date(byAdding: .year, value: 1, to: sessionsInMonth[0].startTime)! >= currentDate {
                        for session in sessionsInMonth {
                            let monthNumber =  cal.component(.month, from: session.startTime)
                            vals[monthNumber - 1] += Double(session.time)
                        }
                    }
                }
                
                let (xLabels, yVals) = shiftLastYear(months: months, vals: vals)
                updateReadChart(dataPoints: xLabels, values: yVals)
            }
            
            if pagesCountChart != nil {
                var vals: [Double] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
                
                for sessionsInMonth in grouppedByMonthSessions {
                    guard !sessionsInMonth.isEmpty else {
                        continue
                    }
                    
                    if cal.date(byAdding: .year, value: 1, to: sessionsInMonth[0].startTime)! >= currentDate {
                        for session in sessionsInMonth {
                            let monthNumber =  cal.component(.month, from: session.startTime)
                            vals[monthNumber - 1] += Double(abs(session.finishPage - session.startPage))
                        }
                    }
                }
                
                let (xLabels, yVals) = shiftLastYear(months: months, vals: vals)
                updatePagesChart(dataPoints: xLabels, values: yVals)
            }
            
            if sessionsCountChart != nil {
                var vals: [Double] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
                
                for sessionsInMonth in grouppedByMonthSessions {
                    guard !sessionsInMonth.isEmpty else {
                        continue
                    }
                    
                    if cal.date(byAdding: .year, value: 1, to: sessionsInMonth[0].startTime)! >= currentDate {
                        let monthNumber =  cal.component(.month, from: sessionsInMonth[0].startTime)
                        vals[monthNumber - 1] = Double(sessionsInMonth.count)
                    }
                }
                
                let (xLabels, yVals) = shiftLastYear(months: months, vals: vals)
                updateSessionsChart(dataPoints: xLabels, values: yVals)
            }
        case .lastMonth:
            var days: [String] = []
            let currentDate = Date()
            let cal = Calendar.current
            let numOfDays = cal.range(of: .day, in: .month, for: cal.date(byAdding: .month, value: -1, to: currentDate)!)!.count
            for i in 1...numOfDays {
                days.append(String(i))
            }
            
            if readTimeChart != nil {
                var vals: [Double] = []
                for _ in 1...numOfDays {
                    vals.append(0)
                }
                
                for sessionsInDay in grouppedByDaySessions {
                    guard !sessionsInDay.isEmpty else {
                        continue
                    }
                    
                    if cal.date(byAdding: .month, value: 1, to: sessionsInDay[0].startTime)! >= currentDate {
                        for session in sessionsInDay {
                            let dayNumber =  cal.component(.day, from: session.startTime)
                            vals[dayNumber - 1] += Double(session.time)
                        }
                    }
                }
                
                let (xLabels, yVals) = shiftLastMonth(days: days, vals: vals)
                updateReadChart(dataPoints: xLabels, values: yVals)
            }
            
            if pagesCountChart != nil {
                var vals: [Double] = []
                for _ in 1...numOfDays {
                    vals.append(0)
                }
                
                for sessionsInDay in grouppedByDaySessions {
                    guard !sessionsInDay.isEmpty else {
                        continue
                    }
                    
                    if cal.date(byAdding: .month, value: 1, to: sessionsInDay[0].startTime)! >= currentDate {
                        for session in sessionsInDay {
                            let dayNumber =  cal.component(.day, from: session.startTime)
                            vals[dayNumber - 1] += Double(abs(session.finishPage - session.startPage))
                        }
                    }
                }
                
                let (xLabels, yVals) = shiftLastMonth(days: days, vals: vals)
                updatePagesChart(dataPoints: xLabels, values: yVals)
            }
            
            if sessionsCountChart != nil {
                var vals: [Double] = []
                for _ in 1...numOfDays {
                    vals.append(0)
                }
                
                for sessionsInDay in grouppedByDaySessions {
                    guard !sessionsInDay.isEmpty else {
                        continue
                    }
                    
                    if cal.date(byAdding: .month, value: 1, to: sessionsInDay[0].startTime)! >= currentDate {
                        let dayNumber =  cal.component(.day, from: sessionsInDay[0].startTime)
                        vals[dayNumber - 1] += Double(sessionsInDay.count)
                    }
                }
                
                let (xLabels, yVals) = shiftLastMonth(days: days, vals: vals)
                updateSessionsChart(dataPoints: xLabels, values: yVals)
            }
        case .lastWeek:
            var days: [String] = []
            let currentDate = Date()
            let cal = Calendar.current
            let numOfDays = cal.range(of: .day, in: .month, for: cal.date(byAdding: .month, value: -1, to: currentDate)!)!.count
            for i in 1...numOfDays {
                days.append(String(i))
            }
            
            if readTimeChart != nil {
                var vals: [Double] = []
                for _ in 1...numOfDays {
                    vals.append(0)
                }
                
                for sessionsInDay in grouppedByDaySessions {
                    guard !sessionsInDay.isEmpty else {
                        continue
                    }
                    
                    if cal.date(byAdding: .month, value: 1, to: sessionsInDay[0].startTime)! >= currentDate {
                        for session in sessionsInDay {
                            let dayNumber =  cal.component(.day, from: session.startTime)
                            vals[dayNumber - 1] += Double(session.time)
                        }
                    }
                }
                
                let (xLabels, yVals) = shiftLastWeek(days: days, vals: vals)
                updateReadChart(dataPoints: xLabels, values: yVals)
            }
            
            if pagesCountChart != nil {
                var vals: [Double] = []
                for _ in 1...numOfDays {
                    vals.append(0)
                }
                
                for sessionsInDay in grouppedByDaySessions {
                    guard !sessionsInDay.isEmpty else {
                        continue
                    }
                    
                    if cal.date(byAdding: .month, value: 1, to: sessionsInDay[0].startTime)! >= currentDate {
                        for session in sessionsInDay {
                            let dayNumber =  cal.component(.day, from: session.startTime)
                            vals[dayNumber - 1] += Double(abs(session.finishPage - session.startPage))
                        }
                    }
                }
                
                let (xLabels, yVals) = shiftLastWeek(days: days, vals: vals)
                updatePagesChart(dataPoints: xLabels, values: yVals)
            }
            
            if sessionsCountChart != nil {
                var vals: [Double] = []
                for _ in 1...numOfDays {
                    vals.append(0)
                }
                
                for sessionsInDay in grouppedByDaySessions {
                    guard !sessionsInDay.isEmpty else {
                        continue
                    }
                    
                    if cal.date(byAdding: .month, value: 1, to: sessionsInDay[0].startTime)! >= currentDate {
                        let dayNumber =  cal.component(.day, from: sessionsInDay[0].startTime)
                        vals[dayNumber - 1] += Double(sessionsInDay.count)
                    }
                }
                
                let (xLabels, yVals) = shiftLastWeek(days: days, vals: vals)
                updateSessionsChart(dataPoints: xLabels, values: yVals)
            }
        case .lastDay:
            var hours: [String] = []
            
            let numOfHrs = 24
            for i in 0..<numOfHrs {
                hours.append(String(i))
            }
            
            
            if readTimeChart != nil {
                var vals: [Double] = []
                for _ in 0..<numOfHrs {
                    vals.append(0)
                }
                
                for session in sessions {
                    if Calendar.current.compare(Date(), to: session.startTime, toGranularity: Calendar.Component.day) == .orderedSame {
                        let hour = Calendar.current.component(.hour, from: session.startTime)
                        vals[hour] += Double(session.time)
                    }
                }
                updateReadChart(dataPoints: hours, values: vals)
            }
            
            if pagesCountChart != nil {
                var vals: [Double] = []
                for _ in 0..<numOfHrs {
                    vals.append(0)
                }
                
                for session in sessions {
                    if Calendar.current.compare(Date(), to: session.startTime, toGranularity: Calendar.Component.day) == .orderedSame {
                        let hour = Calendar.current.component(.hour, from: session.startTime)
                        vals[hour] += Double(abs(session.finishPage - session.startPage))
                    }
                }
                updatePagesChart(dataPoints: hours, values: vals)
            }
            
            if sessionsCountChart != nil {
                var vals: [Double] = []
                for _ in 0..<numOfHrs {
                    vals.append(0)
                }
                
                for session in sessions {
                    if Calendar.current.compare(Date(), to: session.startTime, toGranularity: Calendar.Component.day) == .orderedSame {
                        let hour = Calendar.current.component(.hour, from: session.startTime)
                        vals[hour] += 1.0
                    }
                }
                updateSessionsChart(dataPoints: hours, values: vals)
            }
        }
    }
    
    private func shiftLastYear(months: [String], vals: [Double]) -> ([String], [Double]) {
        let cal = Calendar.current
        let startMonthNumber = cal.component(.month, from: Date()) % 12
        
        var xLabels: [String] = []
        var yVals: [Double] = []
        for i in startMonthNumber..<12 {
            xLabels.append(months[i])
            yVals.append(vals[i])
        }
        
        for i in 0..<startMonthNumber {
            xLabels.append(months[i])
            yVals.append(vals[i])
        }
        
        return (xLabels, yVals)
    }
    
    private func shiftLastMonth(days: [String], vals: [Double]) -> ([String], [Double]) {
        let cal = Calendar.current
        let startDayNumber = cal.component(.day, from: cal.date(byAdding: .month, value: -1, to: Date())!) % days.count
        
        var xLabels: [String] = []
        var yVals: [Double] = []
        for i in startDayNumber..<days.count {
            xLabels.append(days[i])
            yVals.append(vals[i])
        }
        
        for i in 0..<startDayNumber {
            xLabels.append(days[i])
            yVals.append(vals[i])
        }
        
        return (xLabels, yVals)
    }
    
    private func shiftLastWeek(days: [String], vals: [Double]) -> ([String], [Double]) {
        let cal = Calendar.current
        let startDayNumber = cal.component(.day, from: cal.date(byAdding: .month, value: -1, to: Date())!) % days.count
        
        var xLabels: [String] = []
        var yVals: [Double] = []
        for i in startDayNumber..<days.count {
            xLabels.append(days[i])
            yVals.append(vals[i])
        }
        
        for i in 0..<startDayNumber {
            xLabels.append(days[i])
            yVals.append(vals[i])
        }
        
        return (Array(xLabels[xLabels.count-7..<xLabels.count]), Array(yVals[yVals.count-7..<yVals.count]))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        var readTimeChart = LineChartView(forAutoLayout: ())
        view.addSubview(readTimeChart)
        readTimeChart.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 16, left: 0, bottom: 0, right: 0), excludingEdge: .bottom)
        readTimeChart.autoSetDimension(.height, toSize: 200)
        readTimeChart.chartDescription?.text = "Время чтения"
        let marker1: BalloonMarker = BalloonMarker(color: UIColor.black, font: UIFont(name: "Helvetica", size: 12)!, textColor: UIColor.white, insets: UIEdgeInsets(top: 7.0, left: 7.0, bottom: 7.0, right: 7.0), formatter: ToHrsFormatter())
        marker1.minimumSize = CGSize(width: 75.0, height: 35.0)
        readTimeChart.marker = marker1
        setupChart(chart: &readTimeChart)
        self.readTimeChart = readTimeChart

        var pagesCountChart = LineChartView(forAutoLayout: ())
        view.addSubview(pagesCountChart)
        pagesCountChart.autoPinEdge(toSuperviewEdge: .left)
        pagesCountChart.autoPinEdge(toSuperviewEdge: .right)
        pagesCountChart.autoPinEdge(.top, to: .bottom, of: readTimeChart, withOffset: 32)
        pagesCountChart.autoSetDimension(.height, toSize: 200)
        pagesCountChart.chartDescription?.text = "Страницы"
        let marker2: BalloonMarker = BalloonMarker(color: UIColor.black, font: UIFont(name: "Helvetica", size: 12)!, textColor: UIColor.white, insets: UIEdgeInsets(top: 7.0, left: 7.0, bottom: 7.0, right: 7.0), formatter: ToPgsFormatter())
        marker2.minimumSize = CGSize(width: 75.0, height: 35.0)
        pagesCountChart.marker = marker2
        setupChart(chart: &pagesCountChart)
        self.pagesCountChart = pagesCountChart
        
        var sessionsCountChart = LineChartView(forAutoLayout: ())
        view.addSubview(sessionsCountChart)
        sessionsCountChart.autoPinEdge(toSuperviewEdge: .left)
        sessionsCountChart.autoPinEdge(toSuperviewEdge: .right)
        sessionsCountChart.autoPinEdge(toSuperviewEdge: .bottom)
        sessionsCountChart.autoPinEdge(.top, to: .bottom, of: pagesCountChart, withOffset: 32)
        sessionsCountChart.autoSetDimension(.height, toSize: 200)
        sessionsCountChart.chartDescription?.text = "Подходы"
        let marker3: BalloonMarker = BalloonMarker(color: UIColor.black, font: UIFont(name: "Helvetica", size: 12)!, textColor: UIColor.white, insets: UIEdgeInsets(top: 7.0, left: 7.0, bottom: 7.0, right: 7.0), formatter: ToSessFormatter())
        marker3.minimumSize = CGSize(width: 75.0, height: 35.0)
        sessionsCountChart.marker = marker3
        setupChart(chart: &sessionsCountChart)
        self.sessionsCountChart = sessionsCountChart
        
        updateCharts(interval: self.interval)
    }
    
    private func setupChart(chart: inout LineChartView) {
        chart.animate(xAxisDuration: 0.5, yAxisDuration: 0.5, easingOption: .easeInExpo)
        chart.xAxis.drawGridLinesEnabled = false
        chart.leftAxis.drawAxisLineEnabled = false
        chart.rightAxis.enabled = false
        chart.legend.enabled = false
        chart.xAxis.labelPosition = .bottom
        chart.xAxis.granularity = 1
    }
    
    func updateReadChart(dataPoints: [String], values: [Double]) {
        readTimeChart.noDataText = "Нет данных."
        
        var dataEntries: [ChartDataEntry] = []
        
        for i in 0..<dataPoints.count {
            let dataEntry = ChartDataEntry(x: Double(i), y: values[i])
            dataEntries.append(dataEntry)
        }
        
        let chartDataSet = LineChartDataSet(values: dataEntries, label: "")
        chartDataSet.colors = [UIColor(rgb: 0xedaf97)]
        chartDataSet.fillColor = UIColor(rgb: 0xedaf97).withAlphaComponent(0.4)
        chartDataSet.drawFilledEnabled = true
        chartDataSet.circleRadius = 3.0
        chartDataSet.circleColors = [UIColor(rgb: 0xedaf97)]
        chartDataSet.lineWidth = 1.5
        chartDataSet.setDrawHighlightIndicators(false)
        let chartData = LineChartData(dataSets: [chartDataSet])
        chartData.setDrawValues(false)
        readTimeChart.xAxis.valueFormatter = IndexAxisValueFormatter(values: dataPoints)
        readTimeChart.leftAxis.valueFormatter = ToHrsFormatter()
        readTimeChart.data = chartData
        readTimeChart.notifyDataSetChanged()
    }
    
    func updatePagesChart(dataPoints: [String], values: [Double]) {
        pagesCountChart.noDataText = "Нет данных."
        
        var dataEntries: [ChartDataEntry] = []
        
        for i in 0..<dataPoints.count {
            let dataEntry = ChartDataEntry(x: Double(i), y: values[i])
            dataEntries.append(dataEntry)
        }
        
        let chartDataSet = LineChartDataSet(values: dataEntries, label: "")
        chartDataSet.colors = [UIColor(rgb: 0x2f5870)]
        chartDataSet.fillColor = UIColor(rgb: 0x2f5870).withAlphaComponent(0.4)
        chartDataSet.drawFilledEnabled = true
        chartDataSet.circleRadius = 3.0
        chartDataSet.circleColors = [UIColor(rgb: 0x2f5870)]
        chartDataSet.lineWidth = 1.5
        chartDataSet.setDrawHighlightIndicators(false)
        let chartData = LineChartData(dataSets: [chartDataSet])
        chartData.setDrawValues(false)
        pagesCountChart.xAxis.valueFormatter = IndexAxisValueFormatter(values: dataPoints)
        pagesCountChart.leftAxis.valueFormatter = ToPgsFormatter()
        pagesCountChart.data = chartData
        pagesCountChart.notifyDataSetChanged()
    }
    
    func updateSessionsChart(dataPoints: [String], values: [Double]) {
        sessionsCountChart.noDataText = "Нет данных."
        
        var dataEntries: [ChartDataEntry] = []
        
        for i in 0..<dataPoints.count {
            let dataEntry = ChartDataEntry(x: Double(i), y: values[i])
            dataEntries.append(dataEntry)
        }
        
        let chartDataSet = LineChartDataSet(values: dataEntries, label: "")
        chartDataSet.colors = [UIColor(rgb: 0x8aa753)]
        chartDataSet.fillColor = UIColor(rgb: 0x8aa753).withAlphaComponent(0.4)
        chartDataSet.drawFilledEnabled = true
        chartDataSet.circleRadius = 3.0
        chartDataSet.circleColors = [UIColor(rgb: 0x8aa753)]
        chartDataSet.lineWidth = 1.5
        chartDataSet.setDrawHighlightIndicators(false)
        let chartData = LineChartData(dataSets: [chartDataSet])
        chartData.setDrawValues(false)
        sessionsCountChart.xAxis.valueFormatter = IndexAxisValueFormatter(values: dataPoints)
        sessionsCountChart.leftAxis.valueFormatter = ToSessFormatter()
        sessionsCountChart.data = chartData
        sessionsCountChart.notifyDataSetChanged()
    }
    
    private class ToHrsFormatter: IAxisValueFormatter {
        func stringForValue(_ value: Double, axis: AxisBase?) -> String {
            return MarkersFormatter().secsToTimeStr(val: value)
        }
    }
    
    private class ToPgsFormatter: IAxisValueFormatter {
        func stringForValue(_ value: Double, axis: AxisBase?) -> String {
            return MarkersFormatter().pagesStr(val: value)
        }
    }
    
    private class ToSessFormatter: IAxisValueFormatter {
        func stringForValue(_ value: Double, axis: AxisBase?) -> String {
            return MarkersFormatter().sessionsStr(val: value)
        }
    }
    
    private class MarkersFormatter {
        func secsToTimeStr(val: Double) -> String {
            let intSecs = Int(val)
            let mins = (intSecs / 60) % 60
            let hrs = intSecs / 3600
            return "\(hrs) ч \(mins) мин"
        }
        
        func pagesStr(val: Double) -> String {
            return "\(Int(val)) стр"
        }
        
        func sessionsStr(val: Double) -> String {
            return "\(Int(val)) подх"
        }
    }
}

//
//  BalloonMarker.swift
//  ChartsDemo
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/Charts
//

open class BalloonMarker: MarkerImage
{
    open var color: UIColor?
    open var arrowSize = CGSize(width: 15, height: 11)
    open var font: UIFont?
    open var textColor: UIColor?
    open var insets = UIEdgeInsets()
    open var minimumSize = CGSize()
    
    fileprivate var labelns: NSString?
    fileprivate var _labelSize: CGSize = CGSize()
    fileprivate var _paragraphStyle: NSMutableParagraphStyle?
    fileprivate var _drawAttributes = [NSAttributedString.Key : AnyObject]()
    private var formatter: IAxisValueFormatter
    
    public init(color: UIColor, font: UIFont, textColor: UIColor, insets: UIEdgeInsets, formatter: IAxisValueFormatter)
    {
        self.formatter = formatter
        super.init()
        
        self.color = color
        self.font = font
        self.textColor = textColor
        self.insets = insets
        
        _paragraphStyle = NSParagraphStyle.default.mutableCopy() as? NSMutableParagraphStyle
        _paragraphStyle?.alignment = .center
    }
    
    open override func offsetForDrawing(atPoint point: CGPoint) -> CGPoint
    {
        var offset = self.offset
        
        let chart = self.chartView
        
        var size = self.size
        
        if size.width == 0.0 && image != nil
        {
            size.width = image?.size.width ?? 0.0
        }
        if size.height == 0.0 && image != nil
        {
            size.height = image?.size.height ?? 0.0
        }
        
        let width = size.width
        let height = size.height
        let padding = CGFloat(8.0)
        var origin = point;
        origin.x -= width / 2;
        origin.y -= height;
        if origin.x + offset.x < 0.0
        {
            offset.x = -origin.x + padding
        }
        else if chart != nil && origin.x + width + offset.x > chart!.bounds.size.width
        {
            offset.x = chart!.bounds.size.width - origin.x - width - padding
        }
        
        if origin.y + offset.y < 0
        {
            offset.y = height + padding;
        }
        else if chart != nil && origin.y + height + offset.y > chart!.bounds.size.height
        {
            offset.y = chart!.bounds.size.height - origin.y - height - padding
        }
        
        return offset
    }
    
    open override func draw(context: CGContext, point: CGPoint)
    {
        if labelns == nil
        {
            return
        }
        let offset = self.offsetForDrawing(atPoint: point)
        let size = self.size
        
        var rect = CGRect(
            origin: CGPoint(
                x: point.x + offset.x,
                y: point.y + offset.y),
            size: size)
        rect.origin.x -= size.width / 2.0
        rect.origin.y -= size.height
        context.saveGState()
        
        if let color = color
        {
            context.setFillColor(color.cgColor)
            if(offset.y > 0) {
                context.beginPath()
                context.move(to: CGPoint(
                    x: rect.origin.x,
                    y: rect.origin.y + arrowSize.height))
                context.addLine(to: CGPoint(
                    x: rect.origin.x + (rect.size.width - arrowSize.width) / 2.0,
                    y: rect.origin.y + arrowSize.height))
                //arrow vertex
                context.addLine(to: CGPoint(
                    x: point.x,
                    y: point.y))
                context.addLine(to: CGPoint(
                    x: rect.origin.x + (rect.size.width + arrowSize.width) / 2.0,
                    y: rect.origin.y + arrowSize.height))
                context.addLine(to: CGPoint(
                    x: rect.origin.x + rect.size.width,
                    y: rect.origin.y + arrowSize.height))
                context.addLine(to: CGPoint(
                    x: rect.origin.x + rect.size.width,
                    y: rect.origin.y + rect.size.height))
                context.addLine(to: CGPoint(
                    x: rect.origin.x,
                    y: rect.origin.y + rect.size.height))
                context.addLine(to: CGPoint(
                    x: rect.origin.x,
                    y: rect.origin.y + arrowSize.height))
                context.fillPath()
            } else {
                context.beginPath()
                context.move(to: CGPoint(
                    x: rect.origin.x,
                    y: rect.origin.y))
                context.addLine(to: CGPoint(
                    x: rect.origin.x + rect.size.width,
                    y: rect.origin.y))
                context.addLine(to: CGPoint(
                    x: rect.origin.x + rect.size.width,
                    y: rect.origin.y + rect.size.height - arrowSize.height))
                context.addLine(to: CGPoint(
                    x: rect.origin.x + (rect.size.width + arrowSize.width) / 2.0,
                    y: rect.origin.y + rect.size.height - arrowSize.height))
                //arrow vertex
                context.addLine(to: CGPoint(
                    x: point.x,
                    y: point.y))
                context.addLine(to: CGPoint(
                    x: rect.origin.x + (rect.size.width - arrowSize.width) / 2.0,
                    y: rect.origin.y + rect.size.height - arrowSize.height))
                context.addLine(to: CGPoint(
                    x: rect.origin.x,
                    y: rect.origin.y + rect.size.height - arrowSize.height))
                context.addLine(to: CGPoint(
                    x: rect.origin.x,
                    y: rect.origin.y))
                context.fillPath()
            }
        }
        if (offset.y > 0) {
            rect.origin.y += self.insets.top + arrowSize.height
        } else {
            rect.origin.y += self.insets.top
        }
        rect.size.height -= self.insets.top + self.insets.bottom
        
        UIGraphicsPushContext(context)
        
        labelns?.draw(in: rect, withAttributes: _drawAttributes)
        
        UIGraphicsPopContext()
        
        context.restoreGState()
    }
    
    open override func refreshContent(entry: ChartDataEntry, highlight: Highlight) {
        setLabel(formatter.stringForValue(entry.y, axis: nil))
    }
    
    open func setLabel(_ label: String)
    {
        labelns = label as NSString
        
        _drawAttributes.removeAll()
        _drawAttributes[NSAttributedString.Key.font] = self.font
        _drawAttributes[NSAttributedString.Key.paragraphStyle] = _paragraphStyle
        _drawAttributes[NSAttributedString.Key.foregroundColor] = self.textColor
        
        _labelSize = labelns?.size(withAttributes: _drawAttributes) ?? CGSize.zero
        
        var size = CGSize()
        size.width = _labelSize.width + self.insets.left + self.insets.right
        size.height = _labelSize.height + self.insets.top + self.insets.bottom
        size.width = max(minimumSize.width, size.width)
        size.height = max(minimumSize.height, size.height)
        self.size = size
    }
}
