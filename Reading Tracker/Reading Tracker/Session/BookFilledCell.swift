//
//  BookFilledCell.swift
//  Reading Tracker
//
//  Created by Andrei Kirilenko on 11/11/2018.
//  Copyright © 2018 Andrei Kirilenko. All rights reserved.
//

import Foundation
import UIKit

final class BookFilledCell: UIButton {
    private var model: BookModel = BookModel()
    private var titleTextLabel: UILabel?
    private var authorLabel: UILabel?
    private var coverImageView: UIImageView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        setupSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupSubviews() {
        let coverImageView = UIImageView(image: nil)
        coverImageView.contentMode = .scaleAspectFit
        addSubview(coverImageView)
        coverImageView.autoPinEdge(toSuperviewEdge: .right, withInset: 16)
        coverImageView.autoPinEdge(toSuperviewEdge: .top, withInset: 10)
        coverImageView.autoSetDimensions(to: CGSize(width: 70, height: 100))
        
        let titleLabel = UILabel(forAutoLayout: ())
        titleLabel.numberOfLines = 2
        addSubview(titleLabel)
        titleLabel.autoPinEdge(toSuperviewEdge: .left, withInset: 16)
        titleLabel.autoPinEdge(.right, to: .left, of: coverImageView, withOffset: -16)
        titleLabel.autoPinEdge(toSuperviewEdge: .top, withInset: 20)
        
        let authorLabel = UILabel(forAutoLayout: ())
        authorLabel.numberOfLines = 2
        addSubview(authorLabel)
        authorLabel.autoPinEdge(toSuperviewEdge: .left, withInset: 16)
        authorLabel.autoPinEdge(.right, to: .left, of: coverImageView, withOffset: -16)
        authorLabel.autoPinEdge(.top, to: .bottom, of: titleLabel, withOffset: 5)
        authorLabel.autoPinEdge(toSuperviewEdge: .bottom, withInset: 48)
        
        self.titleTextLabel = titleLabel
        self.authorLabel = authorLabel
        self.coverImageView = coverImageView
    }
    
    func configure(model: BookModel) {
        self.model = model
        
        let titleTextAttributes = [
            NSAttributedString.Key.foregroundColor : UIColor(rgb: 0x2f5870),
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: 20, weight: .medium)]
            as [NSAttributedString.Key : Any]
        
        let authorTextAttributes = [
            NSAttributedString.Key.foregroundColor : UIColor(rgb: 0x2f5870),
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14, weight: .medium)]
            as [NSAttributedString.Key : Any]
        
        let title = (model.title.isEmpty ? "Без названия": model.title)
        let author = (model.author.isEmpty ? "Автор не указан": model.author)
        titleTextLabel?.attributedText = NSAttributedString(string: title, attributes: titleTextAttributes)
        authorLabel?.attributedText = NSAttributedString(string: author, attributes: authorTextAttributes)
        if let imageView = coverImageView {
            FirebaseStorageManager.DBManager.downloadCover(into: imageView, bookId: model.id, onImageReceived: ({ img in
                self.model.image = img
            }))
        }
    }
}
