//
//  BookCellAPI.swift
//  Reading Tracker
//
//  Created by Andrei Kirilenko on 07/01/2019.
//  Copyright © 2019 Andrei Kirilenko. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher

class BookCellAPI: UITableViewCell {
    private var titleLabel: UILabel?
    private var authorLabel: UILabel?
    private var coverImageView: UIImageView?
    
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
        titleLabel.numberOfLines = 0
        
        let authorLabel = UILabel(forAutoLayout: ())
        authorLabel.numberOfLines = 0
        
        let coverImageView = UIImageView(image: nil)
        coverImageView.contentMode = .scaleAspectFill
        
        addSubview(titleLabel)
        
        titleLabel.autoPinEdge(toSuperviewEdge: .left, withInset: 16)
        titleLabel.autoPinEdge(toSuperviewEdge: .right, withInset: 16 + 70 + 16)
        titleLabel.autoPinEdge(toSuperviewEdge: .top, withInset: 20)
        
        addSubview(authorLabel)
        
        authorLabel.autoPinEdge(toSuperviewEdge: .left, withInset: 16)
        authorLabel.autoPinEdge(toSuperviewEdge: .right, withInset: 16 + 70 + 16)
        authorLabel.autoPinEdge(.top, to: .bottom, of: titleLabel, withOffset: 5)
        
        addSubview(coverImageView)
        
        coverImageView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 16), excludingEdge: .left)
        coverImageView.autoSetDimensions(to: CGSize(width: 70, height: 100))
        
        self.titleLabel = titleLabel
        self.authorLabel = authorLabel
        self.coverImageView = coverImageView
    }
    
    func configure(model: BookModelAPI) {
        
        let titleTextAttributes = [
            NSAttributedString.Key.foregroundColor : UIColor(rgb: 0x2f5870),
            NSAttributedString.Key.font : UIFont(name: "Avenir-Medium", size: 20.0)!]
            as [NSAttributedString.Key : Any]
        
        let authorTextAttributes = [
            NSAttributedString.Key.foregroundColor : UIColor(rgb: 0x2f5870),
            NSAttributedString.Key.font : UIFont(name: "Avenir-Medium", size: 14.0)!]
            as [NSAttributedString.Key : Any]
        
        titleLabel?.attributedText = NSAttributedString(string: model.title ?? "Без названия", attributes: titleTextAttributes)
        if let authors = model.authors,
            !authors.isEmpty {
            authorLabel?.attributedText = NSAttributedString(string: authors[0], attributes: authorTextAttributes)
        } else {
            authorLabel?.attributedText = NSAttributedString(string: "Автор не указан", attributes: authorTextAttributes)
        }
        
        if let imageView = coverImageView,
            let thumbnail = model.thumbnail {
            let imageTransition = ImageTransition.fade(0.5)
            imageView.kf.indicatorType = .activity
            imageView.kf.setImage(with: URL(string: thumbnail), options: [.transition(imageTransition)])
        }
    }
}
