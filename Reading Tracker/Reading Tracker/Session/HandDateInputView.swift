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
        dateStack.spacing = 4
        
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
        
        let durationLabel = UILabel(forAutoLayout: ())
        
        addSubview(durationLabel)
        durationLabel.autoAlignAxis(toSuperviewAxis: .vertical)
        durationLabel.autoPinEdge(.top, to: .bottom, of: timeIntervalPlate, withOffset: SizeDependent.instance.convertPadding(20))
        self.durationLabel = durationLabel
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
