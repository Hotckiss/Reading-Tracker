//
//  PollView.swift
//  Reading Tracker
//
//  Created by Andrei Kirilenko on 11/12/2018.
//  Copyright © 2018 Andrei Kirilenko. All rights reserved.
//

import Foundation
import UIKit

class PollView: UIView {
    var result: Int?
    private var buttons: [IndexedButton] = []
    
    init(frame: CGRect, title: String, options: [UIImage?]) {
        super.init(frame: frame)
        
        let style = NSMutableParagraphStyle()
        style.alignment = NSTextAlignment.center
        
        let titleTextAttributes = [
            NSAttributedString.Key.foregroundColor : UIColor(rgb: 0x2f5870).withAlphaComponent(0.5),
            NSAttributedString.Key.font : UIFont(name: "Avenir-Light", size: 14.0)!,
            NSAttributedString.Key.paragraphStyle: style]
            as [NSAttributedString.Key : Any]
        
        let titleLabel = UILabel(forAutoLayout: ())
        titleLabel.attributedText = NSAttributedString(string: title, attributes: titleTextAttributes)
        
        addSubview(titleLabel)
        titleLabel.autoPinEdge(toSuperviewEdge: .top)
        titleLabel.autoAlignAxis(toSuperviewAxis: .vertical)
        
        var lastButton: UIButton?
        
        for (index, image) in options.enumerated() {
            let button = IndexedButton(frame: .zero, index: index)
            button.setImage(image?.withRenderingMode(.alwaysTemplate) , for: .normal)
            button.imageView?.tintColor = UIColor(rgb: 0x2f5870).withAlphaComponent(0.5)
            addSubview(button)
            button.autoPinEdge(.top, to: .bottom, of: titleLabel, withOffset: 10)
            button.autoPinEdge(toSuperviewEdge: .bottom)
            button.addTarget(self, action: #selector(onTap(_:)), for: .touchUpInside)
            if let last = lastButton {
                button.autoPinEdge(.left, to: .right, of: last, withOffset: 25)
            } else {
                button.autoPinEdge(toSuperviewEdge: .left)
            }
            buttons.append(button)
            lastButton = button
        }
        
        if let last = lastButton {
            last.autoPinEdge(toSuperviewEdge: .right)
        }
    }
    
    @objc private func onTap(_ sender: IndexedButton) {
        for (index, button) in buttons.enumerated() {
            if index == sender.index {
                button.imageView?.tintColor = UIColor(rgb: 0x2f5870)
            } else {
                button.imageView?.tintColor = UIColor(rgb: 0x2f5870).withAlphaComponent(0.5)
            }
        }
        
        result = sender.index
    }
    
    func setup(index: Int) {
        result = index
        for (i, button) in buttons.enumerated() {
            if i == index {
                button.imageView?.tintColor = UIColor(rgb: 0x2f5870)
            } else {
                button.imageView?.tintColor = UIColor(rgb: 0x2f5870).withAlphaComponent(0.5)
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private class IndexedButton: UIButton {
        let index: Int
        init(frame: CGRect, index: Int) {
            self.index = index
            super.init(frame: frame)
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}
