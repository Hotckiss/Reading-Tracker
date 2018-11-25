//
//  DropdownMenu.swift
//  Reading Tracker
//
//  Created by Andrei Kirilenko on 25/11/2018.
//  Copyright © 2018 Andrei Kirilenko. All rights reserved.
//

import Foundation
import UIKit
import ActionSheetPicker_3_0

class DropdownMenu: UIView {
    var selectedIndex: Int = 0
    private var optionsList: [String]
    private var mainButton: UIButton?
    init(frame: CGRect, optionsList: [String]) {
        self.optionsList = optionsList
        super.init(frame: frame)
        
        setupSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupSubviews() {
        let mainTextAttributes = [
            NSAttributedString.Key.foregroundColor : UIColor(rgb: 0x2f5870).withAlphaComponent(0.5),
            NSAttributedString.Key.font : UIFont(name: "Avenir-Light", size: 20.0)!]
            as [NSAttributedString.Key : Any]
        
        let mainButton = UIButton(forAutoLayout: ())
        mainButton.setAttributedTitle(NSAttributedString(string: "Медиа", attributes: mainTextAttributes), for: [])
        mainButton.contentHorizontalAlignment = .left
        addSubview(mainButton)
        mainButton.autoSetDimension(.height, toSize: 32)
        mainButton.autoPinEdgesToSuperviewEdges(with: .zero)
        
        mainButton.addTarget(self, action: #selector(mainButtonTap(_:)), for: .touchUpInside)
        
        let arrowImageView = UIImageView(image: UIImage(named: "down"))
        mainButton.addSubview(arrowImageView)
        arrowImageView.autoSetDimensions(to: CGSize(width: 10, height: 5))
        arrowImageView.autoAlignAxis(toSuperviewAxis: .horizontal)
        arrowImageView.autoPinEdge(toSuperviewEdge: .right)
        
        let mainButtonLine = UIView(forAutoLayout: ())
        mainButtonLine.backgroundColor = UIColor(rgb: 0x2f5870).withAlphaComponent(0.5)
        addSubview(mainButtonLine)
        mainButtonLine.autoSetDimension(.height, toSize: 1)
        mainButtonLine.autoPinEdge(toSuperviewEdge: .left)
        mainButtonLine.autoPinEdge(toSuperviewEdge: .right)
        mainButtonLine.autoPinEdge(.top, to: .bottom, of: mainButton, withOffset: 8)
        
        self.mainButton = mainButton
    }
    
    @objc private func mainButtonTap(_ sender: UIButton) {
        let picker = ActionSheetMultipleStringPicker(title: "Медиа", rows: [
            optionsList
            ], initialSelection: [selectedIndex], doneBlock: { [weak self]
                picker, values, indexes in
                let textAttributes = [
                    NSAttributedString.Key.foregroundColor : UIColor(rgb: 0x2f5870),
                    NSAttributedString.Key.font : UIFont(name: "Avenir-Medium", size: 20.0)!]
                    as [NSAttributedString.Key : Any]
                if let values = values,
                    let optionIndex = values.first as? Int,
                    let text = self?.optionsList[optionIndex] {
                    self?.selectedIndex = optionIndex
                    sender.setAttributedTitle(NSAttributedString(string: text, attributes: textAttributes), for: [])
                }
                
                return
            }, cancel: { ActionMultipleStringCancelBlock in return }, origin: sender)
        
        picker?.setTextColor(UIColor(rgb: 0x2f5870))
        
        let textAttributes = [
            NSAttributedString.Key.foregroundColor : UIColor(rgb: 0x2f5870),
            NSAttributedString.Key.font : UIFont(name: "Avenir-Medium", size: 17.0)!]
            as [NSAttributedString.Key : Any]
        
        let finishButton = UIButton(forAutoLayout: ())
        finishButton.setAttributedTitle(NSAttributedString(string: "Готово", attributes: textAttributes), for: [])
        picker?.setDoneButton(UIBarButtonItem(customView: finishButton))
        
        let closeButton = UIButton(forAutoLayout: ())
        closeButton.setAttributedTitle(NSAttributedString(string: "Закрыть", attributes: textAttributes), for: [])
        picker?.setCancelButton(UIBarButtonItem(customView: closeButton))
        picker?.show()
    }
    
    func forceUpdate(optionText: String) {
        let textAttributes = [
            NSAttributedString.Key.foregroundColor : UIColor(rgb: 0x2f5870),
            NSAttributedString.Key.font : UIFont(name: "Avenir-Medium", size: 20.0)!]
            as [NSAttributedString.Key : Any]
        
        mainButton?.setAttributedTitle(NSAttributedString(string: optionText, attributes: textAttributes), for: [])
    }
}
