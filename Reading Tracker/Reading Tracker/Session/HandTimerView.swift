//
//  HandTimerView.swift
//  Reading Tracker
//
//  Created by Andrei Kirilenko on 11/11/2018.
//  Copyright © 2018 Andrei Kirilenko. All rights reserved.
//

import Foundation
import UIKit

final class HandTimerView: UIView {
    var time: Int {
        get {
            return 3600 * hours + 60 * minutes
        }
    }
    var hours = 0
    var minutes = 0
    private var hrsView: UILabel!
    private var minsView: UILabel!
    private var hrsUpTimer: Timer!
    private var hrsDownTimer: Timer!
    private var minsUpTimer: Timer!
    private var minsDownTimer: Timer!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let backgroundView = setupBackgroundView()
        setupTimerView(backgroundView: backgroundView)
        let style = NSMutableParagraphStyle()
        style.alignment = NSTextAlignment.center
        
        let textAttributes = [
            NSAttributedString.Key.foregroundColor : UIColor(rgb: 0x2f5870).withAlphaComponent(0.5),
            NSAttributedString.Key.font : UIFont(name: "Avenir-Light", size: 14.0)!,
            NSAttributedString.Key.paragraphStyle: style]
            
            as [NSAttributedString.Key : Any]
        let hrsUpButton = UIButton(forAutoLayout: ())
        let hrsUpLabel = UILabel(forAutoLayout: ())
        hrsUpLabel.attributedText = NSAttributedString(string: "час", attributes: textAttributes)
        let hrsUpImageView = UIImageView(image: UIImage(named: "timeUp"))
        
        hrsUpButton.addSubview(hrsUpLabel)
        hrsUpButton.addSubview(hrsUpImageView)
        addSubview(hrsUpButton)
        hrsUpLabel.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .top)
        hrsUpImageView.autoSetDimensions(to: CGSize(width: 12, height: 7.5))
        hrsUpImageView.autoAlignAxis(.vertical, toSameAxisOf: hrsUpLabel)
        hrsUpImageView.autoPinEdge(.bottom, to: .top, of: hrsUpLabel)
        hrsUpButton.autoSetDimensions(to: CGSize(width: 67, height: 36))
        hrsUpButton.autoAlignAxis(.vertical, toSameAxisOf: hrsView)
        hrsUpButton.autoPinEdge(.bottom, to: .top, of: backgroundView, withOffset: -4)
        
        let minsUpButton = UIButton(forAutoLayout: ())
        let minsUpLabel = UILabel(forAutoLayout: ())
        minsUpLabel.attributedText = NSAttributedString(string: "мин", attributes: textAttributes)
        let minsUpImageView = UIImageView(image: UIImage(named: "timeUp"))
        
        minsUpButton.addSubview(minsUpLabel)
        minsUpButton.addSubview(minsUpImageView)
        addSubview(minsUpButton)
        minsUpLabel.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .top)
        minsUpImageView.autoSetDimensions(to: CGSize(width: 12, height: 7.5))
        minsUpImageView.autoAlignAxis(.vertical, toSameAxisOf: minsUpLabel)
        minsUpImageView.autoPinEdge(.bottom, to: .top, of: minsUpLabel)
        minsUpButton.autoSetDimensions(to: CGSize(width: 67, height: 36))
        minsUpButton.autoAlignAxis(.vertical, toSameAxisOf: minsView)
        minsUpButton.autoPinEdge(.bottom, to: .top, of: backgroundView, withOffset: -4)
        
        let hrsDownButton = UIButton(forAutoLayout: ())
        let hrsDownLabel = UILabel(forAutoLayout: ())
        hrsDownLabel.attributedText = NSAttributedString(string: "час", attributes: textAttributes)
        let hrsDownImageView = UIImageView(image: UIImage(named: "timeDown"))
        
        hrsDownButton.addSubview(hrsDownLabel)
        hrsDownButton.addSubview(hrsDownImageView)
        addSubview(hrsDownButton)
        hrsDownLabel.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .bottom)
        hrsDownImageView.autoSetDimensions(to: CGSize(width: 12, height: 7.5))
        hrsDownImageView.autoAlignAxis(.vertical, toSameAxisOf: hrsDownLabel)
        hrsDownImageView.autoPinEdge(.top, to: .bottom, of: hrsDownLabel)
        hrsDownButton.autoSetDimensions(to: CGSize(width: 67, height: 36))
        hrsDownButton.autoAlignAxis(.vertical, toSameAxisOf: hrsView)
        hrsDownButton.autoPinEdge(.top, to: .bottom, of: backgroundView, withOffset: 4)
        
        let minsDownButton = UIButton(forAutoLayout: ())
        let minsDownLabel = UILabel(forAutoLayout: ())
        minsDownLabel.attributedText = NSAttributedString(string: "мин", attributes: textAttributes)
        let minsDownImageView = UIImageView(image: UIImage(named: "timeDown"))
        
        minsDownButton.addSubview(minsDownLabel)
        minsDownButton.addSubview(minsDownImageView)
        addSubview(minsDownButton)
        minsDownLabel.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .bottom)
        minsDownImageView.autoSetDimensions(to: CGSize(width: 12, height: 7.5))
        minsDownImageView.autoAlignAxis(.vertical, toSameAxisOf: minsDownLabel)
        minsDownImageView.autoPinEdge(.top, to: .bottom, of: minsDownLabel)
        minsDownButton.autoSetDimensions(to: CGSize(width: 67, height: 36))
        minsDownButton.autoAlignAxis(.vertical, toSameAxisOf: minsView)
        minsDownButton.autoPinEdge(.top, to: .bottom, of: backgroundView, withOffset: 4)
        
        hrsUpButton.addTarget(self, action: #selector(hrsUpStart), for: .touchDown)
        hrsUpButton.addTarget(self, action: #selector(hrsUpEnd), for: .touchUpInside)
        hrsDownButton.addTarget(self, action: #selector(hrsDownStart), for: .touchDown)
        hrsDownButton.addTarget(self, action: #selector(hrsDownEnd), for: .touchUpInside)
        
        minsUpButton.addTarget(self, action: #selector(minsUpStart), for: .touchDown)
        minsUpButton.addTarget(self, action: #selector(minsUpEnd), for: .touchUpInside)
        minsDownButton.addTarget(self, action: #selector(minsDownStart), for: .touchDown)
        minsDownButton.addTarget(self, action: #selector(minsDownEnd), for: .touchUpInside)
    }
    
    @objc private func hrsUpStart() {
        hrsUpFire()
        hrsUpTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(hrsUpFire), userInfo: nil, repeats: true)
    }
    
    @objc private func hrsUpEnd() {
        hrsUpTimer.invalidate()
    }
    
    @objc private func hrsUpFire() {
        hours = (hours + 1) % 24
        setTime(hrsLabel: hrsView, minsLabel: minsView)
    }
    
    @objc private func hrsDownStart() {
        hrsDownFire()
        hrsDownTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(hrsDownFire), userInfo: nil, repeats: true)
    }
    
    @objc private func hrsDownEnd() {
        hrsDownTimer.invalidate()
    }
    
    @objc private func hrsDownFire() {
        hours = (hours + 24 - 1) % 24
        setTime(hrsLabel: hrsView, minsLabel: minsView)
    }
    
    @objc private func minsUpStart() {
        minsUpFire()
        minsUpTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(minsUpFire), userInfo: nil, repeats: true)
    }
    
    @objc private func minsUpEnd() {
        minsUpTimer.invalidate()
    }
    
    @objc private func minsUpFire() {
        minutes = (minutes + 1) % 60
        setTime(hrsLabel: hrsView, minsLabel: minsView)
    }
    
    @objc private func minsDownStart() {
        minsDownFire()
        minsDownTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(minsDownFire), userInfo: nil, repeats: true)
    }
    
    @objc private func minsDownEnd() {
        minsDownTimer.invalidate()
    }
    
    @objc private func minsDownFire() {
        minutes = (minutes + 60 - 1) % 60
        setTime(hrsLabel: hrsView, minsLabel: minsView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupBackgroundView() -> UIView {
        let backgroundView = UIView(forAutoLayout: ())
        
        backgroundView.backgroundColor = .white
        backgroundView.layer.cornerRadius = 40
        backgroundView.layer.shadowOffset = CGSize(width: 0, height: 3)
        backgroundView.layer.shadowColor = UIColor.black.cgColor
        backgroundView.layer.shadowOpacity = 0.2
        backgroundView.layer.shadowRadius = 3
        
        addSubview(backgroundView)
        backgroundView.autoPinEdge(toSuperviewEdge: .left)
        backgroundView.autoPinEdge(toSuperviewEdge: .right)
        backgroundView.autoSetDimension(.height, toSize: 80)
        backgroundView.autoPinEdge(toSuperviewEdge: .bottom, withInset: 27 + 4)
        
        return backgroundView
    }
    
    private func setupTimerView(backgroundView: UIView) {
        let hrsView = UILabel(forAutoLayout: ())
        let minsView = UILabel(forAutoLayout: ())
        let dotsView = UILabel(forAutoLayout: ())
        hrsView.textAlignment = .center
        minsView.textAlignment = .center
        dotsView.textAlignment = .center
        
        let timerTextAttributes = [
            NSAttributedString.Key.foregroundColor : UIColor(rgb: 0x2f5870),
            NSAttributedString.Key.font : UIFont(name: "Avenir-Light", size: 64.0)!,
            NSAttributedString.Key.baselineOffset: 4]
            as [NSAttributedString.Key : Any]
        
        dotsView.attributedText = NSAttributedString(string: ":", attributes: timerTextAttributes)
        setTime(hrsLabel: hrsView, minsLabel: minsView)
        backgroundView.addSubview(dotsView)
        dotsView.autoCenterInSuperview()
        
        backgroundView.addSubview(hrsView)
        hrsView.autoAlignAxis(toSuperviewAxis: .horizontal)
        hrsView.autoPinEdge(toSuperviewEdge: .left, withInset: 16)
        hrsView.autoSetDimension(.width, toSize: 67)
        
        backgroundView.addSubview(minsView)
        minsView.autoAlignAxis(toSuperviewAxis: .horizontal)
        minsView.autoPinEdge(toSuperviewEdge: .right, withInset: 16)
        minsView.autoSetDimension(.width, toSize: 67)
        
        self.hrsView = hrsView
        self.minsView = minsView
    }
    
    private func setTime(hrsLabel: UILabel, minsLabel: UILabel) {
        let timerTextAttributes = [
            NSAttributedString.Key.foregroundColor : UIColor(rgb: 0x2f5870),
            NSAttributedString.Key.font : UIFont(name: "Avenir-Light", size: 64.0)!]
            as [NSAttributedString.Key : Any]
        
        hrsLabel.attributedText = NSAttributedString(string: "\(hours)", attributes: timerTextAttributes)
        minsLabel.attributedText = NSAttributedString(string: "\(minutes)", attributes: timerTextAttributes)
    }
}
