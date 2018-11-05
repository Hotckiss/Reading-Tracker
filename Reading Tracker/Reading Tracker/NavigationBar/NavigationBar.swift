//
//  NavigationBar.swift
//  Reading Tracker
//
//  Created by Andrei Kirilenko on 07.10.2018.
//  Copyright © 2018 Andrei Kirilenko. All rights reserved.
//

import Foundation
import UIKit

public struct NavigationBarModel {
    public var title: String
    public var backButtonText: String
    public var frontButtonText: String
    public var onBackButtonPressed: (() -> Void)?
    public var onFrontButtonPressed: (() -> Void)?
    
    init(title: String = "",
         backButtonText: String = "",
         frontButtonText: String = "",
         onBackButtonPressed: (() -> Void)? = nil,
         onFrontButtonPressed: (() -> Void)? = nil) {
        self.title = title
        self.backButtonText = backButtonText
        self.frontButtonText = frontButtonText
        self.onBackButtonPressed = onBackButtonPressed
        self.onFrontButtonPressed = onFrontButtonPressed
    }
}

public class NavigationBar: UIView {
    private var titleLabel: UILabel?
    private var backButton: UIButton?
    private var frontButton: UIButton?
    private var model: NavigationBarModel = NavigationBarModel()
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        
        setupSubviews()
    }
    
    private func setupSubviews() {
        let statusBarHeight = UIApplication.shared.statusBarFrame.height
        
        let backButton = UIButton(frame: .zero)
        backButton.setTitle(model.backButtonText, for: [])
        backButton.addTarget(self, action: #selector(onBack), for: .touchUpInside)
        addSubview(backButton)
        backButton.autoSetDimension(.height, toSize: 32)
        backButton.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: statusBarHeight + 4, left: 16, bottom: 4, right: 0), excludingEdge: .right)
        self.backButton = backButton
        
        let frontButton = UIButton(frame: .zero)
        frontButton.setTitle(model.backButtonText, for: [])
        frontButton.addTarget(self, action: #selector(onFront), for: .touchUpInside)
        addSubview(frontButton)
        frontButton.autoSetDimension(.height, toSize: 32)
        frontButton.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: statusBarHeight + 4, left: 0, bottom: 4, right: 16), excludingEdge: .left)
        self.frontButton = frontButton
        
        let titleLabel = UILabel(frame: .zero)
        titleLabel.text = model.title
        titleLabel.numberOfLines = 0
        titleLabel.textColor = .white
        addSubview(titleLabel)
        titleLabel.autoPinEdge(toSuperviewEdge: .top, withInset: statusBarHeight + 4 + 5)
        titleLabel.autoAlignAxis(toSuperviewAxis: .vertical)
        self.titleLabel = titleLabel
    }
    
    @objc private func onBack() {
        model.onBackButtonPressed?()
    }
    
    @objc private func onFront() {
        model.onFrontButtonPressed?()
    }
    
    public func configure(model: NavigationBarModel) {
        self.model = model
        backButton?.setTitle(model.backButtonText, for: [])
        frontButton?.setTitle(model.frontButtonText, for: [])
        titleLabel?.text = model.title
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
