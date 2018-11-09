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
    //public var onStart: (() -> Void)?
    //public var onPause: (() -> Void)?
    //public var onContinue: (() -> Void)?
    private var shapes: [CAShapeLayer] = []
    private var innerButtonImageView: UIImageView?
    private var titleView: UILabel?
    private var timerView: UILabel?
    private var timer: Timer!
    private var time: Int = 0
    
    public var buttonState: ButtonState = .start {
        didSet {
            setupInnerButton()
            setupTimer()
        }
    }
    
    public var isTappable: Bool = true {
        didSet {}
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setupButton(radius: 115)
        
        let innerButtonImageView = UIImageView(forAutoLayout: ())
        addSubview(innerButtonImageView)
        innerButtonImageView.autoCenterInSuperview()
        innerButtonImageView.autoSetDimensions(to: CGSize(width: 47, height: 63))
        self.innerButtonImageView = innerButtonImageView
        setupInnerButton()
        
        let titleView = UILabel(forAutoLayout: ())
        titleView.numberOfLines = 0
        let titleTextAttributes = [
            NSAttributedString.Key.foregroundColor : UIColor(rgb: 0xedaf97),
            NSAttributedString.Key.font : UIFont(name: "Avenir-Medium", size: 42.0)!]
            as [NSAttributedString.Key : Any]
        titleView.textAlignment = .center
        titleView.attributedText = NSAttributedString(string: "Начать\nчтение", attributes: titleTextAttributes)
        
        addSubview(titleView)
        titleView.autoCenterInSuperview()
        self.titleView = titleView
        
        let timerView = UILabel(forAutoLayout: ())
        timerView.numberOfLines = 0
        timerView.textAlignment = .center
        let timerTextAttributes = [
            NSAttributedString.Key.foregroundColor : UIColor(rgb: 0xedaf97),
            NSAttributedString.Key.font : UIFont(name: "Avenir-Light", size: 64.0)!]
            as [NSAttributedString.Key : Any]
        
        let text = NSMutableAttributedString(string: "00", attributes: timerTextAttributes)
        text.addAttribute(NSAttributedString.Key.font, value: UIFont(name: "Avenir-Light", size: 32.0)!, range: NSRange(location: 1, length: 1))
        text.addAttribute(NSAttributedString.Key.baselineOffset, value: UIFont(name: "Avenir-Light", size: 64.0)!.xHeight - UIFont(name: "Avenir-Light", size: 32.0)!.xHeight, range: NSRange(location: 1, length: 1))
        timerView.attributedText = text
        
        addSubview(timerView)
        timerView.autoCenterInSuperview()
        self.timerView = timerView
        
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(onTick), userInfo: nil, repeats: true)
        timer.invalidate()
        setupTimer()
    }
    
    @objc private func onTick() {
        if buttonState != .start {
            time += 1
        }
        
        let timerTextAttributes = [
            NSAttributedString.Key.foregroundColor : UIColor(rgb: 0xedaf97),
            NSAttributedString.Key.font : UIFont(name: "Avenir-Light", size: 64.0)!]
            as [NSAttributedString.Key : Any]
        
        let mins = time / 60
        let secs = time % 60
        let text = NSMutableAttributedString(string: "\(mins)\(secs)", attributes: timerTextAttributes)
        text.addAttribute(NSAttributedString.Key.font, value: UIFont(name: "Avenir-Light", size: 32.0)!, range: NSRange(location: String(mins).count, length: String(secs).count))
        text.addAttribute(NSAttributedString.Key.baselineOffset, value: UIFont(name: "Avenir-Light", size: 64.0)!.xHeight - UIFont(name: "Avenir-Light", size: 32.0)!.xHeight, range: NSRange(location: String(mins).count, length: String(secs).count))
        timerView?.attributedText = text
    }
    
    private func setupTimer() {
        switch buttonState {
        case .start:
            timerView?.isHidden = true
            titleView?.isHidden = false
            timer.invalidate()
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(onTick), userInfo: nil, repeats: true)
        case .pause:
            timerView?.isHidden = false
            titleView?.isHidden = true
            timer.invalidate()
        case .play:
            timerView?.isHidden = false
            titleView?.isHidden = true
            timer.invalidate()
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(onTick), userInfo: nil, repeats: true)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupButton(radius: CGFloat) {
        backgroundColor = .white
        layer.cornerRadius = radius
        addCircle(radius: radius, width: 7, totalSize: 2 * radius)
        addCircle(radius: radius - 13, width: 1, totalSize: 2 * radius)
        addCircle(radius: radius - 37, width: 0, totalSize: 2 * radius, fillColor: UIColor(rgb: 0xedaf97).withAlphaComponent(0.2).cgColor)
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
