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
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setupButton(radius: 115)
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
