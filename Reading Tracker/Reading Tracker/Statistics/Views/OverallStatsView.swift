//
//  OverallStatsView.swift
//  Reading Tracker
//
//  Created by Andrei Kirilenko on 26/11/2018.
//  Copyright © 2018 Andrei Kirilenko. All rights reserved.
//

import Foundation
import UIKit

public final class OverallStatsView: UIView {
    
    var booksNumLabel: UILabel?
    var hrsNumLabel: UILabel?
    var minsNumLabel: UILabel?
    var approachesNumLabel: UILabel?
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setupButton(radius: 115)
        let style = NSMutableParagraphStyle()
        style.maximumLineHeight = SizeDependent.instance.convertPadding(20)
        
        let textSize = CGFloat(SizeDependent.instance.convertFont(18))
        let booksDescriptionTextAttributes = [
            NSAttributedString.Key.foregroundColor : UIColor(rgb: 0x2f5870),
            NSAttributedString.Key.font : UIFont(name: "Avenir-Light", size: textSize)!,
            NSAttributedString.Key.paragraphStyle: style,
            NSAttributedString.Key.baselineOffset: -4]
            as [NSAttributedString.Key : Any]
        
        let timeDescriptionTextAttributes = [
            NSAttributedString.Key.foregroundColor : UIColor(rgb: 0xedaf97),
            NSAttributedString.Key.font : UIFont(name: "Avenir-Light", size: textSize)!,
            NSAttributedString.Key.paragraphStyle: style,
            NSAttributedString.Key.baselineOffset: -4]
            as [NSAttributedString.Key : Any]
        
        let approachesDescriptionTextAttributes = [
            NSAttributedString.Key.foregroundColor : UIColor(rgb: 0x2f5870).withAlphaComponent(0.5),
            NSAttributedString.Key.font : UIFont(name: "Avenir-Light", size: textSize)!,
            NSAttributedString.Key.paragraphStyle: style,
            NSAttributedString.Key.baselineOffset: -4]
            as [NSAttributedString.Key : Any]
        
        let booksNumLabel = UILabel(forAutoLayout: ())
        self.booksNumLabel = booksNumLabel
        
        let booksTextLabel = UILabel(forAutoLayout: ())
        booksTextLabel.attributedText = NSAttributedString(string: "книг", attributes: booksDescriptionTextAttributes)
        
        let hrsNumLabel = UILabel(forAutoLayout: ())
        self.hrsNumLabel = hrsNumLabel
        
        let hrsTextLabel = UILabel(forAutoLayout: ())
        hrsTextLabel.attributedText = NSAttributedString(string: "час", attributes: timeDescriptionTextAttributes)
        
        let minsNumLabel = UILabel(forAutoLayout: ())
        self.minsNumLabel = minsNumLabel
        
        let minsTextLabel = UILabel(forAutoLayout: ())
        minsTextLabel.attributedText = NSAttributedString(string: "мин", attributes: timeDescriptionTextAttributes)
        
        let approachesNumLabel = UILabel(forAutoLayout: ())
        self.approachesNumLabel = approachesNumLabel
        
        let approachesTextLabel = UILabel(forAutoLayout: ())
        approachesTextLabel.attributedText = NSAttributedString(string: "подходов", attributes: approachesDescriptionTextAttributes)
        
        [booksNumLabel, booksTextLabel, hrsNumLabel, hrsTextLabel, minsNumLabel, minsTextLabel, approachesNumLabel, approachesTextLabel].forEach(({ label in
            label.textAlignment = .center
            self.addSubview(label)
        }))
        
        [booksNumLabel, booksTextLabel, approachesNumLabel, approachesTextLabel].forEach(({ label in
            label.autoAlignAxis(toSuperviewAxis: .vertical)
        }))
        
        [hrsNumLabel, hrsTextLabel, minsNumLabel, minsTextLabel].forEach(({ label in
            label.autoAlignAxis(toSuperviewAxis: .horizontal)
        }))
        
        booksNumLabel.autoPinEdge(toSuperviewEdge: .top, withInset: SizeDependent.instance.convertPadding(20))
        booksTextLabel.autoPinEdge(.top, to: .bottom, of: booksNumLabel)
        
        approachesTextLabel.autoPinEdge(toSuperviewEdge: .bottom, withInset: SizeDependent.instance.convertPadding(32))
        approachesNumLabel.autoPinEdge(.bottom, to: .top, of: approachesTextLabel)
        
        hrsNumLabel.autoPinEdge(toSuperviewEdge: .left, withInset: SizeDependent.instance.convertPadding(25))
        hrsTextLabel.autoPinEdge(.left, to: .right, of: hrsNumLabel, withOffset: 4)
        
        minsTextLabel.autoPinEdge(toSuperviewEdge: .right, withInset: SizeDependent.instance.convertPadding(25))
        minsNumLabel.autoPinEdge(.right, to: .left, of: minsTextLabel, withOffset: -4)
        
        update(booksCount: 0, minsCount: 0, approachesCount: 0)
    }
    
    func update(booksCount: Int, minsCount: Int, approachesCount: Int) {
        let style = NSMutableParagraphStyle()
        style.maximumLineHeight = SizeDependent.instance.convertPadding(36)
        
        let textSize = CGFloat(SizeDependent.instance.convertFont(36))
        let booksNumTextAttributes = [
            NSAttributedString.Key.foregroundColor : UIColor(rgb: 0x2f5870),
            NSAttributedString.Key.font : UIFont(name: "Avenir-Medium", size: textSize)!,
            NSAttributedString.Key.paragraphStyle: style,
            NSAttributedString.Key.baselineOffset: -8]
            as [NSAttributedString.Key : Any]
        
        let timeNumTextAttributes = [
            NSAttributedString.Key.foregroundColor : UIColor(rgb: 0xedaf97),
            NSAttributedString.Key.font : UIFont(name: "Avenir-Medium", size: textSize)!,
            NSAttributedString.Key.paragraphStyle: style,
            NSAttributedString.Key.baselineOffset: -8]
            as [NSAttributedString.Key : Any]
        
        let approachesNumTextAttributes = [
            NSAttributedString.Key.foregroundColor : UIColor(rgb: 0x2f5870).withAlphaComponent(0.5),
            NSAttributedString.Key.font : UIFont(name: "Avenir-Medium", size: textSize)!,
            NSAttributedString.Key.paragraphStyle: style,
            NSAttributedString.Key.baselineOffset: -8]
            as [NSAttributedString.Key : Any]
        
        booksNumLabel?.attributedText = NSAttributedString(string: String(booksCount), attributes: booksNumTextAttributes)
        
        hrsNumLabel?.attributedText = NSAttributedString(string: String(minsCount / 60), attributes: timeNumTextAttributes)
        
        minsNumLabel?.attributedText = NSAttributedString(string: String(minsCount % 60), attributes: timeNumTextAttributes)
        
        approachesNumLabel?.attributedText = NSAttributedString(string: String(approachesCount), attributes: approachesNumTextAttributes)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupButton(radius: CGFloat) {
        let r1 = SizeDependent.instance.convertPadding(radius)
        let r2 = SizeDependent.instance.convertPadding(radius - 13)
        backgroundColor = .white
        layer.cornerRadius = r1
        addCircle(radius: r1, width: SizeDependent.instance.convertPadding(7), totalSize: 2 * r1)
        addCircle(radius: r2, width: 1, totalSize: 2 * r1)
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.2
        layer.shadowOffset = CGSize(width: 0.0, height: 3.0)
    }
    
    private func addCircle(radius: CGFloat, width: CGFloat, totalSize: CGFloat, fillColor: CGColor? = nil) {
        let circle: CAShapeLayer = CAShapeLayer()
        let path: UIBezierPath = UIBezierPath()
        
        path.addArc(withCenter: CGPoint(x: totalSize / 2, y: totalSize / 2),
                    radius: radius,
                    startAngle: -(.pi / 2),
                    endAngle: .pi + .pi / 2,
                    clockwise: true)
        circle.fillColor = fillColor
        circle.strokeColor = UIColor(rgb: 0xedaf97).cgColor
        circle.lineWidth = width
        
        circle.backgroundColor = nil
        circle.path = path.cgPath
        circle.frame = CGRect(x: 0, y: 0, width: totalSize, height: totalSize)
        
        layer.addSublayer(circle)
    }
}
