//
//  StatisticsSessionCell.swift
//  Reading Tracker
//
//  Created by Andrei Kirilenko on 07/12/2018.
//  Copyright © 2018 Andrei Kirilenko. All rights reserved.
//

import Foundation
import UIKit

class SectionCell: UITableViewCell {
    private var titleLabel: UILabel?
    
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
        contentView.addSubview(titleLabel)
        contentView.backgroundColor = .white
        titleLabel.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 16, left: 16, bottom: 6, right: 16))
        self.titleLabel = titleLabel
        
        let lineView = UIView(frame: .zero)
        lineView.backgroundColor = UIColor(rgb: 0x2f5870).withAlphaComponent(0.5)
        
        contentView.addSubview(lineView)
        lineView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16), excludingEdge: .top)
        lineView.autoSetDimension(.height, toSize: 1)
    }
    
    func configure(text: String) {
        let style = NSMutableParagraphStyle()
        style.maximumLineHeight = 20
        style.minimumLineHeight = 20
        style.alignment = .right
        let titleTextAttributes = [
            NSAttributedString.Key.foregroundColor : UIColor(rgb: 0x2f5870).withAlphaComponent(0.5),
            NSAttributedString.Key.font : UIFont(name: "Avenir-Light", size: 14.0)!,
            NSAttributedString.Key.paragraphStyle: style]
            as [NSAttributedString.Key : Any]
        
        titleLabel?.attributedText = NSAttributedString(string: text, attributes: titleTextAttributes)
    }
}
