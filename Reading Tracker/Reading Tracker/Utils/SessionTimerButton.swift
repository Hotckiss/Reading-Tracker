//
//  SessionTimerButton.swift
//  Reading Tracker
//
//  Created by Andrei Kirilenko on 08/11/2018.
//  Copyright © 2018 Andrei Kirilenko. All rights reserved.
//

import Foundation
import UIKit

public final class SessionTimerButton: UIButton {
    public var onStart: (() -> Void)?
    public var onPause: (() -> Void)?
    public var onContinue: (() -> Void)?
    private var circleImageView: UIImageView?
    private var shapes: [CAShapeLayer] = []
    private var innerButtonImageView: UIImageView?
    
    public var buttonState: ButtonState = .start {
        didSet {
            setupInnerButton()
        }
    }
    
    public var isTappable: Bool = false {
        didSet {
        }
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setupButton(radius: 115)
        
        let innerButtonImageView = UIImageView(forAutoLayout: ())
        addSubview(innerButtonImageView)
        innerButtonImageView.autoCenterInSuperview()
        innerButtonImageView.autoSetDimensions(to: CGSize(width: 155, height: 155))
        self.innerButtonImageView = innerButtonImageView
        setupInnerButton()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupButton(radius: CGFloat) {
        backgroundColor = .white
        layer.cornerRadius = radius
        addCircle(radius: radius, width: 7, totalSize: 2 * radius)
        addCircle(radius: radius - 13, width: 1, totalSize: 2 * radius)
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.2
        layer.shadowOffset = CGSize(width: 0.0, height: 3.0)
        
    }
    
    private func addCircle(radius: CGFloat, width: CGFloat, totalSize: CGFloat) {
        let circle: CAShapeLayer = CAShapeLayer()
        let path: UIBezierPath = UIBezierPath()
        
        path.addArc(withCenter: CGPoint(x: totalSize / 2, y: totalSize / 2),
                         radius: radius,
                         startAngle: -(.pi / 2),
                         endAngle: .pi + .pi / 2,
                         clockwise: true)
        circle.fillColor = nil
        circle.strokeColor = UIColor(rgb: 0xedaf97).cgColor
        circle.lineWidth = width
        
        circle.backgroundColor = nil
        circle.path = path.cgPath
        circle.frame = CGRect(x: 0, y: 0, width: totalSize, height: totalSize)
        
        layer.addSublayer(circle)
        shapes.append(circle)
    }
    
    private func setupInnerButton() {
        switch buttonState {
        case .start, .pause:
            innerButtonImageView?.image = UIImage(named: "play")
        case .play:
            innerButtonImageView?.image = UIImage(named: "pause")
        }
    }
    
    public enum ButtonState {
        case start
        case pause
        case play
    }
}
