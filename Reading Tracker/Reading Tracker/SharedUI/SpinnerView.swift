//
//  SpinnerView.swift
//  Reading Tracker
//
//  Created by Andrei Kirilenko on 23/11/2018.
//  Copyright © 2018 Andrei Kirilenko. All rights reserved.
//

import Foundation
import UIKit

class SpinnerView: UIView {
    private var spinner = Spinner()
    
    func show() {
        spinner.isAnimating = true
        isHidden = false
    }
    
    func hide() {
        spinner.isAnimating = false
        isHidden = true
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.white.withAlphaComponent(0.5)
        addSubview(spinner)
        spinner.autoSetDimensions(to: CGSize(width: 56, height: 56))
        spinner.autoCenterInSuperview()
        isHidden = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
