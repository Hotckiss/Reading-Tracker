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
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(sessions: [UploadSessionModel], booksMap: [String : BookModel], interval: StatsInterval) {
        guard !sessions.isEmpty else {
            return
        }
        
        self.sessions = sessions
        self.booksMap = booksMap
        
        let groupedSessions: [(UInt64, [UploadSessionModel])] = Dictionary(grouping: sessions) {
            let daysSince1970 = UInt64($0.startTime.timeIntervalSince1970) / 86400
            return daysSince1970
        }
        .sorted {
            $0.key > $1.key
        }
        
        grouppedByDaySessions = groupedSessions.map { $0.1 }
        
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
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        let months = ["Jan 2018", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
        let unitsSold = [20000.0, 4000.0, 6000.0, 3000.0, 10002.0, 10006.0, 4000.0, 18000.0, 2000.0, 4000.0, 5000.0, 4000.0]
        
        var readTimeChart = LineChartView(forAutoLayout: ())
        view.addSubview(readTimeChart)
        readTimeChart.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 16, left: 0, bottom: 0, right: 0), excludingEdge: .bottom)
        readTimeChart.autoSetDimension(.height, toSize: 200)
        readTimeChart.chartDescription?.text = "Время чтения в день"
        setupChart(chart: &readTimeChart)
        self.readTimeChart = readTimeChart

        updateReadChart(dataPoints: months, values: unitsSold)
        
        var pagesCountChart = LineChartView(forAutoLayout: ())
        view.addSubview(pagesCountChart)
        pagesCountChart.autoPinEdge(toSuperviewEdge: .left)
        pagesCountChart.autoPinEdge(toSuperviewEdge: .right)
        pagesCountChart.autoPinEdge(.top, to: .bottom, of: readTimeChart, withOffset: 32)
        pagesCountChart.autoSetDimension(.height, toSize: 200)
        pagesCountChart.chartDescription?.text = "Страниц в день"
        setupChart(chart: &pagesCountChart)
        self.pagesCountChart = pagesCountChart
        
        updatePagesChart(dataPoints: months, values: unitsSold)
        
        var sessionsCountChart = LineChartView(forAutoLayout: ())
        view.addSubview(sessionsCountChart)
        sessionsCountChart.autoPinEdge(toSuperviewEdge: .left)
        sessionsCountChart.autoPinEdge(toSuperviewEdge: .right)
        sessionsCountChart.autoPinEdge(toSuperviewEdge: .bottom)
        sessionsCountChart.autoPinEdge(.top, to: .bottom, of: pagesCountChart, withOffset: 32)
        sessionsCountChart.autoSetDimension(.height, toSize: 200)
        sessionsCountChart.chartDescription?.text = "Подходов в день"
        setupChart(chart: &sessionsCountChart)
        self.sessionsCountChart = sessionsCountChart
        
        updateSessionsChart(dataPoints: months, values: unitsSold)
    }
    
    private func setupChart(chart: inout LineChartView) {
        chart.animate(xAxisDuration: 0.5, yAxisDuration: 0.5, easingOption: .easeInExpo)
        chart.xAxis.drawGridLinesEnabled = false
        chart.leftAxis.drawAxisLineEnabled = false
        chart.rightAxis.enabled = false
        chart.legend.enabled = false
        chart.xAxis.labelPosition = .bottom
        chart.xAxis.granularity = 1
        let marker: BalloonMarker = BalloonMarker(color: UIColor.black, font: UIFont(name: "Helvetica", size: 12)!, textColor: UIColor.white, insets: UIEdgeInsets(top: 7.0, left: 7.0, bottom: 7.0, right: 7.0))
        marker.minimumSize = CGSize(width: 75.0, height: 35.0)
        chart.marker = marker
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
        pagesCountChart.leftAxis.valueFormatter = ToHrsFormatter()
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
        sessionsCountChart.leftAxis.valueFormatter = ToHrsFormatter()
        sessionsCountChart.data = chartData
        sessionsCountChart.notifyDataSetChanged()
    }
    
    private class ToHrsFormatter: IAxisValueFormatter {
        func stringForValue(_ value: Double, axis: AxisBase?) -> String {
            return MarkersFormatter().secsToTimeStr(val: value)
        }
    }
}


private class MarkersFormatter {
    func secsToTimeStr(val: Double) -> String {
        let intSecs = Int(val)
        let mins = (intSecs / 60) % 60
        let hrs = intSecs / 3600
        return "\(hrs) ч \(mins) мин"
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
    
    public init(color: UIColor, font: UIFont, textColor: UIColor, insets: UIEdgeInsets)
    {
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
        setLabel(MarkersFormatter().secsToTimeStr(val: entry.y))
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
