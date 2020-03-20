//
//  BookSessionTimesCell.swift
//  Reading Tracker
//
//  Created by Andrei Kirilenko on 08/12/2018.
//  Copyright © 2018 Andrei Kirilenko. All rights reserved.
//

import Foundation
import UIKit

class BookSessionTimesCell: UITableViewCell {
    private var dateLabel: UILabel?
    private var dayOfWeekLabel: UILabel?
    private var timeIntervalLabel: UILabel?
    
    private var hrsNumLabel: UILabel?
    private var hrsTextLabel: UILabel?
    private var minsNumLabel: UILabel?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .white
        selectionStyle = .none
        setupSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupSubviews() {
        let dateLabel = UILabel(forAutoLayout: ())
        dateLabel.numberOfLines = 1
        contentView.addSubview(dateLabel)
        dateLabel.autoPinEdge(toSuperviewEdge: .left, withInset: 16)
        dateLabel.autoPinEdge(toSuperviewEdge: .top, withInset: 20)
        
        let dayOfWeekLabel = UILabel(forAutoLayout: ())
        dayOfWeekLabel.numberOfLines = 1
        contentView.addSubview(dayOfWeekLabel)
        dayOfWeekLabel.autoPinEdge(.left, to: .right, of: dateLabel, withOffset: 4)
        dayOfWeekLabel.autoAlignAxis(.horizontal, toSameAxisOf: dateLabel)
        
        let timeIntervalLabel = UILabel(forAutoLayout: ())
        timeIntervalLabel.numberOfLines = 0
        contentView.addSubview(timeIntervalLabel)
        timeIntervalLabel.autoPinEdge(toSuperviewEdge: .left, withInset: 16)
        timeIntervalLabel.autoPinEdge(toSuperviewEdge: .bottom, withInset: 20)
        timeIntervalLabel.autoPinEdge(.top, to: .bottom, of: dateLabel, withOffset: 16)
        self.dateLabel = dateLabel
        self.dayOfWeekLabel = dayOfWeekLabel
        self.timeIntervalLabel = timeIntervalLabel
        
        let style = NSMutableParagraphStyle()
        style.maximumLineHeight = SizeDependent.instance.convertPadding(20)
        let textSize = CGFloat(SizeDependent.instance.convertFont(18))
        
        let timeDescriptionTextAttributes = [
            NSAttributedString.Key.foregroundColor : UIColor(rgb: 0xedaf97),
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: textSize, weight: .regular),
            NSAttributedString.Key.paragraphStyle: style,
            NSAttributedString.Key.baselineOffset: -2]
            as [NSAttributedString.Key : Any]
        
        let hrsNumLabel = UILabel(forAutoLayout: ())
        self.hrsNumLabel = hrsNumLabel
        
        let hrsTextLabel = UILabel(forAutoLayout: ())
        hrsTextLabel.attributedText = NSAttributedString(string: "ч", attributes: timeDescriptionTextAttributes)
        self.hrsTextLabel = hrsTextLabel
        
        let minsNumLabel = UILabel(forAutoLayout: ())
        self.minsNumLabel = minsNumLabel
        
        let minsTextLabel = UILabel(forAutoLayout: ())
        minsTextLabel.attributedText = NSAttributedString(string: "мин", attributes: timeDescriptionTextAttributes)
        
        [minsTextLabel, minsNumLabel, hrsTextLabel, hrsNumLabel].forEach { [weak self] label in
            self?.contentView.addSubview(label)
        }
        
        minsTextLabel.autoPinEdge(toSuperviewEdge: .top, withInset: 24)
        
        minsTextLabel.autoPinEdge(toSuperviewEdge: .right, withInset: 16)
        minsNumLabel.autoPinEdge(.right, to: .left, of: minsTextLabel, withOffset: -4)
        
        hrsTextLabel.autoPinEdge(.right, to: .left, of: minsNumLabel, withOffset: -6)
        hrsNumLabel.autoPinEdge(.right, to: .left, of: hrsTextLabel, withOffset: -4)
        
        [minsNumLabel, hrsTextLabel, hrsNumLabel].forEach { label in
            label.autoAlignAxis(.horizontal, toSameAxisOf: minsTextLabel)
        }
    }
    
    func configure(model: UploadSessionModel) {
        let style = NSMutableParagraphStyle()
        style.maximumLineHeight = SizeDependent.instance.convertPadding(36)
        
        let textSize = CGFloat(SizeDependent.instance.convertFont(36))
        
        let timeNumTextAttributes = [
            NSAttributedString.Key.foregroundColor : UIColor(rgb: 0xedaf97),
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: textSize, weight: .medium),
            NSAttributedString.Key.paragraphStyle: style,
            NSAttributedString.Key.baselineOffset: -6]
            as [NSAttributedString.Key : Any]
        
        let dateTextAttributes = [
            NSAttributedString.Key.foregroundColor : UIColor(rgb: 0x2f5870),
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: 20, weight: .medium)]
            as [NSAttributedString.Key : Any]
        
        let dayOfWeekTextAttributes = [
            NSAttributedString.Key.foregroundColor : UIColor(rgb: 0x2f5870).withAlphaComponent(0.5),
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14, weight: .regular)]
            as [NSAttributedString.Key : Any]
        
        let timeIntervalTextAttributes = [
            NSAttributedString.Key.foregroundColor : UIColor(rgb: 0x2f5870),
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14, weight: .medium)]
            as [NSAttributedString.Key : Any]
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "HH:mm"
        
        let startTimeString = formatter.string(from: model.startTime)
        let finishTimeString = formatter.string(from: model.finishTime)
        
        let timeIntervalString = startTimeString + " \u{2013} " + finishTimeString
        dateLabel?.attributedText = NSAttributedString(string: format(model.startTime), attributes: dateTextAttributes)
        dayOfWeekLabel?.attributedText = NSAttributedString(string: getDayOfWeek(model.startTime), attributes: dayOfWeekTextAttributes)
        timeIntervalLabel?.attributedText = NSAttributedString(string: timeIntervalString, attributes: timeIntervalTextAttributes)
        minsNumLabel?.attributedText = NSAttributedString(string: String((model.time / 60) % 60), attributes: timeNumTextAttributes)
        hrsNumLabel?.attributedText = NSAttributedString(string: String(model.time / 3600), attributes: timeNumTextAttributes)
        
        hrsTextLabel?.isHidden = (model.time / 3600) == 0
        hrsNumLabel?.isHidden = (model.time / 3600) == 0
    }
    
    public func format(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "d MMMM"
        return formatter.string(from: date)
    }
    
    func getDayOfWeek(_ date: Date) -> String {
        var cal = Calendar(identifier: .gregorian)
        cal.locale = Locale(identifier: "ru_RU")
        let weekDay = cal.component(.weekday, from: date)
        return SessionCell.weedDayMap[weekDay]!
    }
    
    static let weedDayMap: [Int: String] = [
        1: "воскресенье",
        2: "понедельник",
        3: "вторник",
        4: "среда",
        5: "четверг",
        6: "пятница",
        7: "суббота",
        ]
}
