//
//  PeriodSelectionView.swift
//  Reading Tracker
//
//  Created by Andrei Kirilenko on 01/12/2018.
//  Copyright © 2018 Andrei Kirilenko. All rights reserved.
//

import Foundation

import Foundation
import UIKit

public final class PeriodSelectionView: UIView {
    var onTap: (() -> Void)?
    
    private var titleLabel: UILabel?
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        
        let titleLabel = UILabel(forAutoLayout: ())
        titleLabel.textAlignment = .center
        addSubview(titleLabel)
        self.titleLabel = titleLabel
       
        let button = UIButton(forAutoLayout: ())
        button.setImage(UIImage(named: "dots"), for: .normal)
        addSubview(button)
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        
        titleLabel.autoAlignAxis(toSuperviewAxis: .vertical)
        titleLabel.autoPinEdge(toSuperviewEdge: .top, withInset: 8)
        titleLabel.autoPinEdge(toSuperviewEdge: .bottom, withInset: 8)
        button.autoPinEdge(.left, to: .right, of: titleLabel, withOffset: 8)
        button.autoSetDimensions(to: CGSize(width: 32, height: 32))
        button.autoAlignAxis(toSuperviewAxis: .horizontal)
    }
    
    func update(title: String) {
        let textAttributes = [
            NSAttributedString.Key.foregroundColor : UIColor(rgb: 0x2f5870),
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: 18, weight: .medium)]
            as [NSAttributedString.Key : Any]
        
        titleLabel?.attributedText = NSAttributedString(string: title, attributes: textAttributes)
    }
    
    @objc private func buttonTapped() {
        onTap?()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
