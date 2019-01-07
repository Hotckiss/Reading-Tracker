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
        let coverImageView = UIImageView(image: nil)
        coverImageView.contentMode = .scaleAspectFit
        contentView.addSubview(coverImageView)
        coverImageView.autoPinEdge(toSuperviewEdge: .right, withInset: 16)
        coverImageView.autoPinEdge(toSuperviewEdge: .top, withInset: 10)
        coverImageView.autoSetDimensions(to: CGSize(width: 70, height: 100))
        
        let titleLabel = UILabel(forAutoLayout: ())
        titleLabel.numberOfLines = 0
        contentView.addSubview(titleLabel)
        titleLabel.autoPinEdge(toSuperviewEdge: .left, withInset: 16)
        titleLabel.autoPinEdge(.right, to: .left, of: coverImageView, withOffset: -16)
        titleLabel.autoPinEdge(toSuperviewEdge: .top, withInset: 20)
        
        let authorLabel = UILabel(forAutoLayout: ())
        authorLabel.numberOfLines = 0
        contentView.addSubview(authorLabel)
        authorLabel.autoPinEdge(toSuperviewEdge: .left, withInset: 16)
        authorLabel.autoPinEdge(.right, to: .left, of: coverImageView, withOffset: -16)
        authorLabel.autoPinEdge(.top, to: .bottom, of: titleLabel, withOffset: 5)
        authorLabel.autoPinEdge(toSuperviewEdge: .bottom, withInset: 48)
        
        self.titleLabel = titleLabel
        self.authorLabel = authorLabel
        self.coverImageView = coverImageView
        print(contentView)
    }
    
    func configure(model: BookModelAPI) {
        
        let titleTextAttributes = [
            NSAttributedString.Key.foregroundColor : UIColor(rgb: 0x2f5870),
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: 20, weight: .medium)]
            as [NSAttributedString.Key : Any]
        
        let authorTextAttributes = [
            NSAttributedString.Key.foregroundColor : UIColor(rgb: 0x2f5870),
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14, weight: .medium)]
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
    
    func markAsAdded() {
        contentView.backgroundColor = UIColor(rgb: 0x8aff53).withAlphaComponent(0.5)
    }
    
    func image() -> UIImage? {
        return coverImageView?.image
    }
}
