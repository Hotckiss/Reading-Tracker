//
//  PollView.swift
//  Reading Tracker
//
//  Created by Andrei Kirilenko on 11/12/2018.
//  Copyright © 2018 Andrei Kirilenko. All rights reserved.
//

import Foundation
import UIKit

struct PollViewOption {
    var image: UIImage?
    var text: String?
}

class PollView: UIView {
    var result: Int?
    private var buttons: [IndexedButton] = []
    private var labels: [UILabel] = []
    
    init(frame: CGRect, title: String, options: [PollViewOption]) {
        super.init(frame: frame)
        
        let style = NSMutableParagraphStyle()
        style.alignment = NSTextAlignment.center
        
        let titleTextAttributes = [
            NSAttributedString.Key.foregroundColor : UIColor(rgb: 0x2f5870).withAlphaComponent(0.5),
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14, weight: .regular),
            NSAttributedString.Key.paragraphStyle: style]
            as [NSAttributedString.Key : Any]
        
        let titleLabel = UILabel(forAutoLayout: ())
        titleLabel.attributedText = NSAttributedString(string: title, attributes: titleTextAttributes)
        
        addSubview(titleLabel)
        titleLabel.autoPinEdge(toSuperviewEdge: .top)
        titleLabel.autoAlignAxis(toSuperviewAxis: .vertical)
        
        var lastButton: UIButton?
        
        for (index, option) in options.enumerated() {
            let button = IndexedButton(frame: .zero, index: index)
            button.setImage(option.image?.withRenderingMode(.alwaysTemplate) , for: .normal)
            button.imageView?.tintColor = UIColor(rgb: 0x2f5870).withAlphaComponent(0.5)
            addSubview(button)
            button.autoPinEdge(.top, to: .bottom, of: titleLabel, withOffset: 10)
            button.addTarget(self, action: #selector(onTap(_:)), for: .touchUpInside)
            if let last = lastButton {
                button.autoPinEdge(.left, to: .right, of: last, withOffset: 25)
            } else {
                button.autoPinEdge(toSuperviewEdge: .left)
            }
            buttons.append(button)
            lastButton = button
            
            var lastLabel: UILabel?
            
            if let text = option.text {
                let textAttributes = [
                    NSAttributedString.Key.foregroundColor : UIColor(rgb: 0x2f5870).withAlphaComponent(0.5),
                    NSAttributedString.Key.font : UIFont.systemFont(ofSize: 11, weight: .regular)]
                    as [NSAttributedString.Key : Any]
                
                let buttonLabel = UILabel(forAutoLayout: ())
                buttonLabel.attributedText = NSAttributedString(string: text, attributes: textAttributes)
                addSubview(buttonLabel)
                if let last = lastLabel{
                    buttonLabel.autoAlignAxis(.horizontal, toSameAxisOf: last)
                } else {
                    buttonLabel.autoPinEdge(.top, to: .bottom, of: button, withOffset: 4)
                    lastLabel = buttonLabel
                }
                buttonLabel.autoPinEdge(toSuperviewEdge: .bottom)
                buttonLabel.autoAlignAxis(.vertical, toSameAxisOf: button)
                labels.append(buttonLabel)
            } else {
                button.autoPinEdge(toSuperviewEdge: .bottom)
            }
        }
        
        if let last = lastButton {
            last.autoPinEdge(toSuperviewEdge: .right)
        }
    }
    
    @objc private func onTap(_ sender: IndexedButton) {
        for (index, button) in buttons.enumerated() {
            if index == sender.index {
                button.imageView?.tintColor = UIColor(rgb: 0x2f5870)
                labels[index].textColor = UIColor(rgb: 0x2f5870)
            } else {
                button.imageView?.tintColor = UIColor(rgb: 0x2f5870).withAlphaComponent(0.5)
                labels[index].textColor = UIColor(rgb: 0x2f5870).withAlphaComponent(0.5)
            }
        }
        
        result = sender.index
    }
    
    func setup(index: Int) {
        result = index
        for (i, button) in buttons.enumerated() {
            if i == index {
                button.imageView?.tintColor = UIColor(rgb: 0x2f5870)
                if i < labels.count {
                    labels[i].textColor = UIColor(rgb: 0x2f5870)
                }
            } else {
                button.imageView?.tintColor = UIColor(rgb: 0x2f5870).withAlphaComponent(0.5)
                if i < labels.count {
                    labels[i].textColor = UIColor(rgb: 0x2f5870).withAlphaComponent(0.5)
                }
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
