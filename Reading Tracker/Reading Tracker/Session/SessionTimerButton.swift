//
//  SessionTimerButton.swift
//  Reading Tracker
//
//  Created by Andrei Kirilenko on 08/11/2018.
//  Copyright © 2018 Andrei Kirilenko. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

public final class SessionTimerButton: UIButton {
    private var disposeBag = DisposeBag()
    
    public var time: Int = 0
    public var startTime: Date?
    public var onStateChanged: ((ButtonState) -> Void)?
    private var shapes: [CAShapeLayer] = []
    private var innerButtonImageView: UIImageView?
    private var titleView: UILabel?
    private var timerView: UILabel?
    private var timer: Timer!
    
    public var buttonState: ButtonState = .start {
        didSet {
            if oldValue == .start && buttonState != .start {
                startTime = Date()
            }
            setupInnerButton()
            setupTimer()
            onStateChanged?(buttonState)
        }
    }
    
    public var isPlaceholder: Bool = false {
        didSet {
            let scale = SizeDependent.instance.scale(230, persentage: 55)
            isUserInteractionEnabled = !isPlaceholder
            let textSize = 42 * scale
            let titleTextAttributes = [
                NSAttributedString.Key.foregroundColor : isPlaceholder ? UIColor(rgb: 0xbdbdbd) : UIColor(rgb: 0xedaf97),
                NSAttributedString.Key.font : UIFont.systemFont(ofSize: textSize, weight: .medium)]
                as [NSAttributedString.Key : Any]
            titleView?.attributedText = NSAttributedString(string: "Начать\nчтение", attributes: titleTextAttributes)
            
            if isPlaceholder {
                for shape in shapes {
                    shape.strokeColor = UIColor(rgb: 0xbdbdbd).cgColor
                }
                
                if !shapes.isEmpty {
                    shapes[shapes.count - 1].fillColor = UIColor(rgb: 0xeeeeee).cgColor
                }
                timerView?.isHidden = true
                titleView?.isHidden = false
            } else {
                for shape in shapes {
                    shape.strokeColor = UIColor(rgb: 0xedaf97).cgColor
                }
                
                if !shapes.isEmpty {
                    shapes[shapes.count - 1].fillColor = UIColor(rgb: 0xedaf97).withAlphaComponent(0.2).cgColor
                }
                timerView?.isHidden = (buttonState == .start)
                titleView?.isHidden = (buttonState != .start)
            }
            
        }
    }
    
    func reset() {
        isPlaceholder = false
        time = 0
        setTimeText()
        startTime = nil
        buttonState = .start
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        let scale = SizeDependent.instance.scale(230, persentage: 55)
        setupButton(radius: scale * 115)
        
        let innerButtonImageView = UIImageView(forAutoLayout: ())
        addSubview(innerButtonImageView)
        innerButtonImageView.autoCenterInSuperview()
        innerButtonImageView.autoSetDimensions(to: CGSize(width: 47, height: 63))
        self.innerButtonImageView = innerButtonImageView
        setupInnerButton()
        
        let titleView = UILabel(forAutoLayout: ())
        titleView.numberOfLines = 0
        let textSize = 42 * scale
        let titleTextAttributes = [
            NSAttributedString.Key.foregroundColor : UIColor(rgb: 0xedaf97),
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: textSize, weight: .medium)]
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
            NSAttributedString.Key.font : UIFont(name: "Courier", size: 64 * scale)!]
            as [NSAttributedString.Key : Any]
        
        let text = NSMutableAttributedString(string: "00", attributes: timerTextAttributes)
        text.addAttribute(NSAttributedString.Key.font, value: UIFont(name: "Courier", size: 32 * scale)!, range: NSRange(location: 1, length: 1))
        text.addAttribute(NSAttributedString.Key.baselineOffset, value: UIFont(name: "Courier", size: 64 * scale)!.xHeight - UIFont(name: "Courier", size: 32 * scale)!.xHeight, range: NSRange(location: 1, length: 1))
        timerView.attributedText = text
        
        addSubview(timerView)
        timerView.autoCenterInSuperview()
        self.timerView = timerView
        
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(onTick), userInfo: nil, repeats: true)
        timer.invalidate()
        setupTimer()
        
        TimerBackgroundHelper
            .timeInBackgroundObservable
            .subscribe(onNext: ({ [weak self] backgroundTime in
                guard let strongSelf = self else {
                    return
                }
                if strongSelf.buttonState == .play {
                    strongSelf.time += backgroundTime
                }
                strongSelf.setTimeText()
        })).disposed(by: disposeBag)
    }
    
    @objc private func onTick() {
        if buttonState != .start {
            time += 1
        }
        
        setTimeText()
    }
    
    private func setTimeText() {
        let scale = SizeDependent.instance.scale(230, persentage: 55)
        let bigFont = UIFont(name: "Courier", size: 64 * scale)!
        let smallFont = UIFont(name: "Courier", size: 32 * scale)!
        let timerTextAttributes = [
            NSAttributedString.Key.foregroundColor : UIColor(rgb: 0xedaf97),
            NSAttributedString.Key.font : bigFont]
            as [NSAttributedString.Key : Any]
        
        let mins = time / 60
        let secs = time % 60
        let secsString = ((secs < 10) ? "0\(secs)" : String(secs))
        let text = NSMutableAttributedString(string: "\(mins)\(secsString)", attributes: timerTextAttributes)
        text.addAttribute(NSAttributedString.Key.font, value: smallFont, range: NSRange(location: String(mins).count, length: String(secsString).count))
        text.addAttribute(NSAttributedString.Key.baselineOffset, value: bigFont.xHeight - smallFont.xHeight, range: NSRange(location: String(mins).count, length: String(secsString).count))
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
        let r1 = radius
        let r2 = radius - SizeDependent.instance.convertPadding(13)
        let r3 = radius - SizeDependent.instance.convertPadding(28)
        backgroundColor = .white
        layer.cornerRadius = r1
        addCircle(radius: r1, width: SizeDependent.instance.convertPadding(7), totalSize: 2 * r1)
        addCircle(radius: r2, width: 1, totalSize: 2 * r1)
        addCircle(radius: r3, width: 0, totalSize: 2 * r1, fillColor: UIColor(rgb: 0xedaf97).withAlphaComponent(0.2).cgColor)
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
