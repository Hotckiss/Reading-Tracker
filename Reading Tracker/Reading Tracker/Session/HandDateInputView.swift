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
    private var date = Date()
    private var startDateTime = Date()
    private var finishDateTime = Date()
    private var dateLabel: UIButton?
    private var timeIntervalStartLabel: UIButton?
    private var timeIntervalFinishLabel: UIButton?
    private var durationLabel: UILabel?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupSubviews()
    }
    
    func reset() {
        let currentTime = Date()
        configure(startDateTime: currentTime, finishDateTime: currentTime, date: currentTime)
    }
    
    func getDates() -> (Date, Date, Int) {
        let calendar = Calendar.current
        
        var startRes = date
        var finishRes = date
        
        let startHrs = calendar.component(.hour, from: startDateTime)
        let startMins = calendar.component(.minute, from: startDateTime)
        let startSecs = calendar.component(.second, from: startDateTime)
        startRes = calendar.date(bySettingHour: startHrs, minute: startMins, second: startSecs, of: startRes)!
        
        let finishHrs = calendar.component(.hour, from: finishDateTime)
        let finishMins = calendar.component(.minute, from: finishDateTime)
        let finishSecs = calendar.component(.second, from: finishDateTime)
        finishRes = calendar.date(bySettingHour: finishHrs, minute: finishMins, second: finishSecs, of: finishRes)!
        
        if finishRes < startRes {
            finishRes = calendar.date(byAdding: .day, value: 1, to: finishRes)!
        }
        
        let duration = Int(finishRes.timeIntervalSince1970 - startRes.timeIntervalSince1970)
        
        return (startRes, finishRes, duration)
    }
    
    private func setupSubviews() {
        let calendarIcon = UIImageView(image: UIImage(named: "calendar"))
        let dateLabel = UIButton(forAutoLayout: ())
        dateLabel.addTarget(self, action: #selector(datePressed(_:)), for: .touchUpInside)
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
        timeIntervalStartLabel.addTarget(self, action: #selector(startTimePressed(_:)), for: .touchUpInside)
        self.timeIntervalStartLabel = timeIntervalStartLabel
        
        let timeIntervalFinishLabel = UIButton(forAutoLayout: ())
        timeIntervalFinishLabel.addTarget(self, action: #selector(finishTimePressed(_:)), for: .touchUpInside)
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
        durationLabel.autoPinEdge(toSuperviewEdge: .bottom)
        durationLabel.autoPinEdge(.top, to: .bottom, of: timeIntervalPlate, withOffset: SizeDependent.instance.convertPadding(20))
        self.durationLabel = durationLabel
        
        configure(startDateTime: startDateTime, finishDateTime: finishDateTime, date: date)
    }
    
    @objc private func datePressed(_ sender: UIButton) {
        let picker = ActionSheetDatePicker(title: "Дата чтения", datePickerMode: .date, selectedDate: date, doneBlock: { picker, values, indexes in
            if let selectedDate = values as? Date {
                self.date = selectedDate
                self.configure(startDateTime: self.startDateTime, finishDateTime: self.finishDateTime, date: self.date)
            }
            return
        }, cancel: { ActionMultipleStringCancelBlock in return }, origin: sender)
        
        runPicker(picker)
    }
    
    @objc private func startTimePressed(_ sender: UIButton) {
        let picker = ActionSheetDatePicker(title: "Начало чтения", datePickerMode: .time, selectedDate: startDateTime, doneBlock: { picker, values, indexes in
            if let selectedDate = values as? Date {
                self.startDateTime = selectedDate
                self.configure(startDateTime: self.startDateTime, finishDateTime: self.finishDateTime, date: self.date)
            }
            return
            }, cancel: { ActionMultipleStringCancelBlock in return }, origin: sender)
        
        runPicker(picker)
    }
    
    @objc private func finishTimePressed(_ sender: UIButton) {
        let picker = ActionSheetDatePicker(title: "Конец чтения", datePickerMode: .time, selectedDate: finishDateTime, doneBlock: { picker, values, indexes in
            if let selectedDate = values as? Date {
                self.finishDateTime = selectedDate
                self.configure(startDateTime: self.startDateTime, finishDateTime: self.finishDateTime, date: self.date)
            }
            return
            }, cancel: { ActionMultipleStringCancelBlock in return }, origin: sender)
        
        runPicker(picker)
    }
    
    private func runPicker(_ picker: ActionSheetDatePicker?) {
        picker?.locale = Locale(identifier: "ru_RU")
        picker?.setTextColor(UIColor(rgb: 0x2f5870))
        
        let textAttributes = [
            NSAttributedString.Key.foregroundColor : UIColor(rgb: 0x2f5870),
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: 17)]
            as [NSAttributedString.Key : Any]
        
        let finishButton = UIButton(frame: CGRect(x: 0, y: 0, width: 70, height: 35))
        finishButton.setAttributedTitle(NSAttributedString(string: "Готово", attributes: textAttributes), for: [])
        picker?.setDoneButton(UIBarButtonItem(customView: finishButton))
        
        let closeButton = UIButton(frame: CGRect(x: 0, y: 0, width: 70, height: 35))
        closeButton.setAttributedTitle(NSAttributedString(string: "Закрыть", attributes: textAttributes), for: [])
        picker?.setCancelButton(UIBarButtonItem(customView: closeButton))
        picker?.show()
    }
    
    func configure(startDateTime: Date, finishDateTime: Date, date: Date) {
        let dateString = format(date)
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
        
        let startTimeString = formatter.string(from: startDateTime)
        let startTimeIntervalString = NSMutableAttributedString(string: startTimeString, attributes: timeIntervalTextAttributesSmall)
        startTimeIntervalString.addAttributes(timeIntervalTextAttributesBig, range: NSRange(location: 0, length: 2))
        timeIntervalStartLabel?.setAttributedTitle(startTimeIntervalString, for: .normal)
        
        let finishTimeString = formatter.string(from: finishDateTime)
        let finishTimeIntervalString = NSMutableAttributedString(string: finishTimeString, attributes: timeIntervalTextAttributesSmall)
        finishTimeIntervalString.addAttributes(timeIntervalTextAttributesBig, range: NSRange(location: 0, length: 2))
        timeIntervalFinishLabel?.setAttributedTitle(finishTimeIntervalString, for: .normal)
        
        let durationInt = Int64(finishDateTime.timeIntervalSince1970 - startDateTime.timeIntervalSince1970)
        
        let duration: UInt64 = UInt64(durationInt >= 0 ? durationInt : durationInt + 86400)
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
