//
//  PageTextField.swift
//  Reading Tracker
//
//  Created by Andrei Kirilenko on 11/11/2018.
//  Copyright © 2018 Andrei Kirilenko. All rights reserved.
//

import Foundation
import UIKit

final class PageTextField: UIView, UITextFieldDelegate {
    var page: Int? {
        get {
            guard let text = textField.text,
                let result = Int(text) else {
                    return nil
            }
            return result
        }
    }
    
    private var topPlaceholder: UILabel!
    private var emptyPlaceholder: UILabel!
    private var textField: RTTextField!
    private var bottomLine: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let topPlaceholder = UILabel(forAutoLayout: ())
        topPlaceholder.numberOfLines = 0
        let placeholderTextAttributes = [
            NSAttributedString.Key.foregroundColor : UIColor(rgb: 0x2f5870).withAlphaComponent(0.5),
            NSAttributedString.Key.font : UIFont(name: "Avenir-Light", size: 14.0)!]
            as [NSAttributedString.Key : Any]
        topPlaceholder.attributedText = NSAttributedString(string: "Начальная\nстраница", attributes: placeholderTextAttributes)
        
        let emptyPlaceholder = UILabel(forAutoLayout: ())
        emptyPlaceholder.numberOfLines = 0
        emptyPlaceholder.attributedText = NSAttributedString(string: "Начальная\nстраница", attributes: placeholderTextAttributes)
        
        let textField = RTTextField(frame: .zero)
        let textFieldAttributes = [
            NSAttributedString.Key.foregroundColor : UIColor(rgb: 0x2f5870),
            NSAttributedString.Key.font : UIFont(name: "Avenir-Medium", size: 20.0)!]
            as [NSAttributedString.Key : Any]
        
        textField.defaultTextAttributes = textFieldAttributes
        textField.textAlignment = .center
        textField.keyboardType = .decimalPad
        let bottomLine = UIView(forAutoLayout: ())
        bottomLine.backgroundColor = UIColor(rgb: 0x2f5870).withAlphaComponent(0.5)
        
        addSubview(topPlaceholder)
        topPlaceholder.autoAlignAxis(toSuperviewAxis: .vertical)
        topPlaceholder.autoPinEdge(toSuperviewEdge: .top)
        
        addSubview(emptyPlaceholder)
        emptyPlaceholder.autoAlignAxis(toSuperviewAxis: .vertical)
        emptyPlaceholder.autoPinEdge(.top, to: .bottom, of: topPlaceholder, withOffset: 4)
        
        addSubview(textField)
        textField.autoPinEdge(toSuperviewEdge: .left)
        textField.autoPinEdge(toSuperviewEdge: .right)
        textField.autoPinEdge(.top, to: .bottom, of: topPlaceholder, withOffset: 4)
        textField.autoSetDimension(.height, toSize: 38)
        textField.delegate = self
        
        let accessoryView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 40))
        accessoryView.backgroundColor = UIColor(rgb: 0xe5e5e5)
        let finishButton = UIButton(forAutoLayout: ())
        finishButton.setAttributedTitle(NSAttributedString(string: "Готово", attributes: textFieldAttributes), for: [])
        textField.inputAccessoryView = accessoryView
        accessoryView.addSubview(finishButton)
        finishButton.addTarget(self, action: #selector(hideKeyboard), for: .touchUpInside)
        finishButton.autoPinEdge(toSuperviewEdge: .right, withInset: 16)
        finishButton.autoAlignAxis(toSuperviewAxis: .horizontal)
        
        addSubview(bottomLine)
        bottomLine.autoPinEdge(.top, to: .bottom, of: textField, withOffset: 10)
        bottomLine.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .top)
        bottomLine.autoSetDimension(.height, toSize: 1)
        
        topPlaceholder.isHidden = true
        
        self.topPlaceholder = topPlaceholder
        self.textField = textField
        self.emptyPlaceholder = emptyPlaceholder
        self.bottomLine = bottomLine
    }
    
    @objc private func hideKeyboard() {
        textField.endEditing(true)
    }
    
    func configure(placeholder: String) {
        let placeholderTextAttributes = [
            NSAttributedString.Key.foregroundColor : UIColor(rgb: 0x2f5870).withAlphaComponent(0.5),
            NSAttributedString.Key.font : UIFont(name: "Avenir-Light", size: 14.0)!]
            as [NSAttributedString.Key : Any]
        
        topPlaceholder.attributedText = NSAttributedString(string: placeholder, attributes: placeholderTextAttributes)
        emptyPlaceholder.attributedText = NSAttributedString(string: placeholder, attributes: placeholderTextAttributes)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let text = textField.text,
            text.count > 0 {
            topPlaceholder.isHidden = false
            emptyPlaceholder.isHidden = true
        } else {
            topPlaceholder.isHidden = true
            emptyPlaceholder.isHidden = false
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        topPlaceholder.isHidden = false
        emptyPlaceholder.isHidden = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func disable(disable: Bool) {
        textField.isEnabled = !disable
    }
}
