//
//  BookEmptyCell.swift
//  Reading Tracker
//
//  Created by Andrei Kirilenko on 11/11/2018.
//  Copyright © 2018 Andrei Kirilenko. All rights reserved.
//

import Foundation
import UIKit

final class BookEmptyCell: UIView {
    var onAdd: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.2
        layer.shadowOffset = CGSize(width: 0.0, height: 3.0)
        setupSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupSubviews() {
        let titleTextLabel = UILabel(forAutoLayout: ())
        
        let titleTextAttributes = [
            NSAttributedString.Key.foregroundColor : UIColor(rgb: 0x2f5870),
            NSAttributedString.Key.font : UIFont(name: "Avenir-Medium", size: 20.0)!]
            as [NSAttributedString.Key : Any]
        
        titleTextLabel.attributedText = NSAttributedString(string: "Для начала добавьте книгу, которую сейчас читаете", attributes: titleTextAttributes)
        titleTextLabel.numberOfLines = 0
        
        let addButton = UIButton(forAutoLayout: ())
        
        addButton.backgroundColor = UIColor(rgb: 0x2f5870)
        let icon = UIImage(named: "plus")
        addButton.imageEdgeInsets = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        addButton.setImage(icon, for: [])
        addButton.addTarget(self, action: #selector(addBook), for: .touchUpInside)
        addButton.layer.cornerRadius = 30
        addButton.layer.shadowColor = UIColor.black.cgColor
        addButton.layer.shadowOpacity = 0.2
        addButton.layer.shadowOffset = CGSize(width: 0.0, height: 3.0)
        
        addSubview(titleTextLabel)
        
        titleTextLabel.autoPinEdge(toSuperviewEdge: .left, withInset: 16)
        titleTextLabel.autoPinEdge(toSuperviewEdge: .right, withInset: 16 + 70 + 16)
        titleTextLabel.autoPinEdge(toSuperviewEdge: .top, withInset: 20)
        titleTextLabel.autoPinEdge(toSuperviewEdge: .bottom, withInset: 16)
        
        addSubview(addButton)
        
        addButton.autoSetDimensions(to: CGSize(width: 60, height: 60))
        addButton.autoPinEdge(toSuperviewEdge: .right, withInset: 16)
        addButton.autoAlignAxis(toSuperviewAxis: .horizontal)
    }
    
    @objc private func addBook() {
        onAdd?()
    }
}
