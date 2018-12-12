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
    private var dateLabel: UIButton?
    private var timeIntervalStartLabel: UIButton?
    private var timeIntervalFinishLabel: UIButton?
    private var durationLabel: UILabel?

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupSubviews()
    }
    
    private func setupSubviews() {
        let calendarIcon = UIImageView(image: UIImage(named: "calendar"))
        let dateLabel = UIButton(forAutoLayout: ())
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
        
        let timeIntervalSeparatorLabel = UILabel(forAutoLayout: ())
        let timeIntervalSeparatorAttributes = [
            NSAttributedString.Key.foregroundColor : UIColor(rgb: 0x2f5870).withAlphaComponent(0.5),
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: SizeDependent.instance.convertFont(24), weight: .light),
            NSAttributedString.Key.baselineOffset: 0]
            as [NSAttributedString.Key : Any]
        timeIntervalSeparatorLabel.attributedText = NSAttributedString(string: " \u{2013} ", attributes: timeIntervalSeparatorAttributes)
        
        let timeIntervalStartLabel = UIButton(forAutoLayout: ())
        self.timeIntervalStartLabel = timeIntervalStartLabel
        
        let timeIntervalFinishLabel = UIButton(forAutoLayout: ())
        self.timeIntervalFinishLabel = timeIntervalFinishLabel
        
        
        let timeIntervalStack = UIStackView(arrangedSubviews: [timeIntervalStartLabel, timeIntervalSeparatorLabel, timeIntervalFinishLabel])
        timeIntervalStack.axis = .horizontal
        timeIntervalStack.alignment = .center
        timeIntervalStack.spacing = 4
        timeIntervalPlate.addSubview(timeIntervalStack)
        timeIntervalStack.autoCenterInSuperview()
        
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
        dateLabel?.setAttributedTitle(NSAttributedString(string: dateString, attributes: dateTextAttributes), for: .normal)
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "HH : mm"
        
        let timeIntervalTextAttributesSmall = [
            NSAttributedString.Key.foregroundColor : UIColor(rgb: 0x2f5870),
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: SizeDependent.instance.convertFont(24), weight: .light),
            NSAttributedString.Key.baselineOffset: SizeDependent.instance.convertPadding(8)]
            as [NSAttributedString.Key : Any]
        
        let timeIntervalTextAttributesBig = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: SizeDependent.instance.convertFont(48), weight: .light),
                                             NSAttributedString.Key.baselineOffset: 0] as [NSAttributedString.Key : Any]
        
        let startTimeString = formatter.string(from: startDate)
        let startTimeIntervalString = NSMutableAttributedString(string: startTimeString, attributes: timeIntervalTextAttributesSmall)
        startTimeIntervalString.addAttributes(timeIntervalTextAttributesBig, range: NSRange(location: 0, length: 2))
        timeIntervalStartLabel?.setAttributedTitle(startTimeIntervalString, for: .normal)
        
        let finishTimeString = formatter.string(from: finishDate)
        let finishTimeIntervalString = NSMutableAttributedString(string: finishTimeString, attributes: timeIntervalTextAttributesSmall)
        finishTimeIntervalString.addAttributes(timeIntervalTextAttributesBig, range: NSRange(location: 0, length: 2))
        timeIntervalFinishLabel?.setAttributedTitle(finishTimeIntervalString, for: .normal)
        
        let duration: UInt64 = UInt64(finishDate.timeIntervalSince1970 - startDate.timeIntervalSince1970)
        let mins = (duration / 60) % 60
        let hrs = duration / 3600
        let durationText = String(format: "%d : %02d", hrs, mins)
        
        let durationTextAttributesSmall = [
            NSAttributedString.Key.foregroundColor : UIColor(rgb: 0xedaf97),
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: SizeDependent.instance.convertFont(24), weight: .light),
            NSAttributedString.Key.baselineOffset: SizeDependent.instance.convertPadding(8)]
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
