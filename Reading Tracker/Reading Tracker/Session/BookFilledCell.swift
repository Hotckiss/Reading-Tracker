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
    private var model: BookModel = BookModel(title: "", author: "")
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
        let titleTextLabel = UILabel(forAutoLayout: ())
        titleTextLabel.numberOfLines = 0
        
        let authorLabel = UILabel(forAutoLayout: ())
        authorLabel.numberOfLines = 0
        
        let coverImageView = UIImageView(image: model.image)
        coverImageView.contentMode = .scaleAspectFill
        
        addSubview(titleTextLabel)
        
        titleTextLabel.autoPinEdge(toSuperviewEdge: .left, withInset: 16)
        titleTextLabel.autoPinEdge(toSuperviewEdge: .right, withInset: 16 + 70 + 16)
        titleTextLabel.autoPinEdge(toSuperviewEdge: .top, withInset: 20)
        
        addSubview(authorLabel)
        
        authorLabel.autoPinEdge(toSuperviewEdge: .left, withInset: 16)
        authorLabel.autoPinEdge(toSuperviewEdge: .right, withInset: 16 + 70 + 16)
        authorLabel.autoPinEdge(.top, to: .bottom, of: titleTextLabel, withOffset: 5)
        
        addSubview(coverImageView)
        
        coverImageView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 16), excludingEdge: .left)
        coverImageView.autoSetDimensions(to: CGSize(width: 70, height: 100))
        
        self.titleTextLabel = titleTextLabel
        self.authorLabel = authorLabel
        self.coverImageView = coverImageView
    }
    
    func configure(model: BookModel) {
        self.model = model
        
        let titleTextAttributes = [
            NSAttributedString.Key.foregroundColor : UIColor(rgb: 0x2f5870),
            NSAttributedString.Key.font : UIFont(name: "Avenir-Medium", size: 20.0)!]
            as [NSAttributedString.Key : Any]
        
        let authorTextAttributes = [
            NSAttributedString.Key.foregroundColor : UIColor(rgb: 0x2f5870),
            NSAttributedString.Key.font : UIFont(name: "Avenir-Medium", size: 14.0)!]
            as [NSAttributedString.Key : Any]
        
        titleTextLabel?.attributedText = NSAttributedString(string: model.title, attributes: titleTextAttributes)
        authorLabel?.attributedText = NSAttributedString(string: model.author, attributes: authorTextAttributes)
        if let imageView = coverImageView {
            FirebaseStorageManager.DBManager.downloadCover(into: imageView, bookId: model.id, onImageReceived: ({ img in
                self.model.image = img
            }))
        }
    }
}
