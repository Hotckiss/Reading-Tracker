//
//  HandDateInputView.swift
//  Reading Tracker
//
//  Created by Andrei Kirilenko on 12/12/2018.
//  Copyright © 2018 Andrei Kirilenko. All rights reserved.
//

import Foundation
import UIKit
import ActionSheetPicker_3_0

final class HandDateInputView: UIView {
    private var dateLabel: UILabel?
    private var timeIntervalLabel: UILabel?
    private var durationLabel: UILabel?

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupSubviews()
    }
    
    private func setupSubviews() {
        let calendarIcon = UIImageView(image: UIImage(named: "calendar"))
        let dateLabel = UILabel(forAutoLayout: ())
        let dateStack = UIStackView(arrangedSubviews: [calendarIcon, dateLabel])
        dateStack.axis = .horizontal
        dateStack.alignment = .center
        dateStack.spacing = 6
        
        addSubview(dateStack)
        dateStack.autoAlignAxis(toSuperviewMarginAxis: .vertical)
        dateStack.autoPinEdge(toSuperviewEdge: .top)
        self.dateLabel = dateLabel
        
        let timeIntervalPlate = UIView(forAutoLayout: ())
        
        timeIntervalPlate.backgroundColor = .white
        timeIntervalPlate.layer.cornerRadius = 35
        timeIntervalPlate.layer.shadowRadius = 4
        timeIntervalPlate.layer.shadowColor = UIColor.black.cgColor
        timeIntervalPlate.layer.shadowOpacity = 0.33
        timeIntervalPlate.layer.shadowOffset = CGSize(width: 0.0, height: 4.0)
        
        addSubview(timeIntervalPlate)
        timeIntervalPlate.autoPinEdge(toSuperviewEdge: .left, withInset: 16)
        timeIntervalPlate.autoPinEdge(toSuperviewEdge: .right, withInset: 16)
        timeIntervalPlate.autoPinEdge(.top, to: .bottom, of: dateStack, withOffset: SizeDependent.instance.convertPadding(20))
        timeIntervalPlate.autoSetDimension(.height, toSize: 70)
        
        let timeIntervalLabel = UILabel(forAutoLayout: ())
        timeIntervalPlate.addSubview(timeIntervalLabel)
        timeIntervalLabel.autoCenterInSuperview()
        self.timeIntervalLabel = timeIntervalLabel
        
        let durationLabel = UILabel(forAutoLayout: ())
        addSubview(durationLabel)
        durationLabel.autoAlignAxis(toSuperviewAxis: .vertical)
        durationLabel.autoPinEdge(.top, to: .bottom, of: timeIntervalPlate, withOffset: SizeDependent.instance.convertPadding(20))
        self.durationLabel = durationLabel
        
        configure(startDate: Date(), finishDate: Date())
    }
    
    func configure(startDate: Date, finishDate: Date) {
        let dateString = format(startDate)
        let dateTextAttributes = [
            NSAttributedString.Key.foregroundColor : UIColor(rgb: 0x2f5870),
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: SizeDependent.instance.convertFont(20), weight: .medium)]
            as [NSAttributedString.Key : Any]
        dateLabel?.attributedText = NSAttributedString(string: dateString, attributes: dateTextAttributes)
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "HH : mm"
        
        let timeIntervalTextAttributesSmall = [
            NSAttributedString.Key.foregroundColor : UIColor(rgb: 0x2f5870),
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: SizeDependent.instance.convertFont(24), weight: .light),
            NSAttributedString.Key.baselineOffset: SizeDependent.instance.convertFont(8)]
            as [NSAttributedString.Key : Any]
        
        let timeIntervalSeparatorAttributes = [NSAttributedString.Key.foregroundColor : UIColor(rgb: 0x2f5870).withAlphaComponent(0.5)]
        let timeIntervalTextAttributesBig = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: SizeDependent.instance.convertFont(48), weight: .light),
                                             NSAttributedString.Key.baselineOffset: 0] as [NSAttributedString.Key : Any]
        
        let startTimeString = formatter.string(from: startDate)
        let finishTimeString = formatter.string(from: finishDate)
        let sepString = " \u{2013} "
        let timeIntervalString = startTimeString + sepString + finishTimeString
        
        let intervalString = NSMutableAttributedString(string: timeIntervalString, attributes: timeIntervalTextAttributesSmall)
        intervalString.addAttributes(timeIntervalTextAttributesBig, range: NSRange(location: 0, length: 2))
        intervalString.addAttributes(timeIntervalTextAttributesBig, range: NSRange(location: startTimeString.count + sepString.count, length: 2))
        intervalString.addAttributes(timeIntervalSeparatorAttributes, range: NSRange(location: startTimeString.count + 1, length: 1))
        
        timeIntervalLabel?.attributedText = intervalString
        
        let duration: UInt64 = UInt64(finishDate.timeIntervalSince1970 - startDate.timeIntervalSince1970)
        
        let mins = (duration / 60) % 60
        let hrs = duration / 3600
        
        let durationText = String(format: "%d : %02d", hrs, mins)
        
        let durationTextAttributesSmall = [
            NSAttributedString.Key.foregroundColor : UIColor(rgb: 0xedaf97),
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: SizeDependent.instance.convertFont(24), weight: .light),
            NSAttributedString.Key.baselineOffset: SizeDependent.instance.convertFont(8)]
            as [NSAttributedString.Key : Any]
        
        let durationTextAttributesBig = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: SizeDependent.instance.convertFont(48), weight: .light),
            NSAttributedString.Key.baselineOffset: 0]
            as [NSAttributedString.Key : Any]
        
        let durationAttributedText = NSMutableAttributedString(string: durationText, attributes: durationTextAttributesSmall)
        durationAttributedText.addAttributes(durationTextAttributesBig, range: NSRange(location: 0, length: String(hrs).count))
        durationLabel?.attributedText = durationAttributedText
    }
    
    private func format(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "d MMMM"
        return formatter.string(from: date)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
