//
//  ProfileCell.swift
//  Reading Tracker
//
//  Created by Andrei Kirilenko on 1/19/19.
//  Copyright © 2019 Andrei Kirilenko. All rights reserved.
//

import Foundation
import UIKit

final class ProfileCell: UITableViewCell {
    private var model: ProfileOption = ProfileOption(title: "")
    private var titleLabel: UILabel?
    private var subtitleLabel: UILabel?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .white
        selectionStyle = .none
        setupSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupSubviews() {
        let titleLabel = UILabel(forAutoLayout: ())
        
        let titleTextAttributes = [
            NSAttributedString.Key.foregroundColor : UIColor(rgb: 0x2f5870),
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: 20, weight: .medium)]
            as [NSAttributedString.Key : Any]
        
        titleLabel.attributedText = NSAttributedString(string: model.title, attributes: titleTextAttributes)
        titleLabel.numberOfLines = 0
        
        contentView.addSubview(titleLabel)
        
        titleLabel.autoPinEdge(toSuperviewEdge: .left, withInset: 16)
        titleLabel.autoPinEdge(toSuperviewEdge: .right, withInset: 16)
        titleLabel.autoPinEdge(toSuperviewEdge: .top, withInset: 30)
        
        let subtitleLabel = UILabel(forAutoLayout: ())
        
        let subtitleTextAttributes = [
            NSAttributedString.Key.foregroundColor : UIColor(rgb: 0x2f5870).withAlphaComponent(0.5),
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16, weight: .regular)]
            as [NSAttributedString.Key : Any]
        
        subtitleLabel.attributedText = NSAttributedString(string: model.subtitle, attributes: subtitleTextAttributes)
        subtitleLabel.numberOfLines = 0
        contentView.addSubview(subtitleLabel)
        
        subtitleLabel.autoPinEdge(toSuperviewEdge: .left, withInset: 16)
        subtitleLabel.autoPinEdge(toSuperviewEdge: .right, withInset: 16)
        subtitleLabel.autoPinEdge(toSuperviewEdge: .bottom, withInset: 30)
        subtitleLabel.autoPinEdge(.top, to: .bottom, of: titleLabel, withOffset: 5)
        
        self.titleLabel = titleLabel
        self.subtitleLabel = subtitleLabel
    }
    
    func configure(model: ProfileOption) {
        self.model = model
        
        let titleTextAttributes = [
            NSAttributedString.Key.foregroundColor : UIColor(rgb: 0x2f5870),
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: 20, weight: .medium)]
            as [NSAttributedString.Key : Any]
        
        let subtitleTextAttributes = [
            NSAttributedString.Key.foregroundColor : UIColor(rgb: 0x2f5870).withAlphaComponent(0.5),
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16, weight: .regular)]
            as [NSAttributedString.Key : Any]
        
        titleLabel?.attributedText = NSAttributedString(string: model.title, attributes: titleTextAttributes)
        subtitleLabel?.attributedText = NSAttributedString(string: model.subtitle, attributes: subtitleTextAttributes)
    }
}
