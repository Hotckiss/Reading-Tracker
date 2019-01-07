//
//  BookSessionsCell.swift
//  Reading Tracker
//
//  Created by Andrei Kirilenko on 07/12/2018.
//  Copyright © 2018 Andrei Kirilenko. All rights reserved.
//

import Foundation
import UIKit

public struct BookSessionsCellModel {
    var book: BookModel
    var attempts: Int
    var time: Int
    
    public init(book: BookModel = BookModel(), attempts: Int = 0, time: Int = 0) {
        self.book = book
        self.attempts = attempts
        self.time = time
    }
}

class BookSessionsCell: UITableViewCell {
    private var titleLabel: UILabel?
    private var authorLabel: UILabel?
    
    private var hrsNumLabel: UILabel?
    private var minsNumLabel: UILabel?
    
    private var attemptsNumLabel: UILabel?
    private var attemptsTextLabel: UILabel?
    
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
        titleLabel.numberOfLines = 1
        contentView.addSubview(titleLabel)
        titleLabel.autoPinEdge(toSuperviewEdge: .left, withInset: 16)
        titleLabel.autoPinEdge(toSuperviewEdge: .right, withInset: 16)
        titleLabel.autoPinEdge(toSuperviewEdge: .top, withInset: 16)
        
        let authorLabel = UILabel(forAutoLayout: ())
        authorLabel.numberOfLines = 1
        contentView.addSubview(authorLabel)
        authorLabel.autoPinEdge(toSuperviewEdge: .left, withInset: 16)
        authorLabel.autoPinEdge(toSuperviewEdge: .right, withInset: 16)
        authorLabel.autoPinEdge(.top, to: .bottom, of: titleLabel)
        self.titleLabel = titleLabel
        self.authorLabel = authorLabel
        
        let style = NSMutableParagraphStyle()
        style.maximumLineHeight = SizeDependent.instance.convertPadding(20)
        let textSize = CGFloat(SizeDependent.instance.convertFont(18))
        
        let timeDescriptionTextAttributes = [
            NSAttributedString.Key.foregroundColor : UIColor(rgb: 0xedaf97),
            NSAttributedString.Key.font : UIFont(name: "Avenir-Light", size: textSize)!,
            NSAttributedString.Key.paragraphStyle: style,
            NSAttributedString.Key.baselineOffset: -4]
            as [NSAttributedString.Key : Any]
        
        let hrsNumLabel = UILabel(forAutoLayout: ())
        self.hrsNumLabel = hrsNumLabel
        
        let hrsTextLabel = UILabel(forAutoLayout: ())
        hrsTextLabel.attributedText = NSAttributedString(string: "ч", attributes: timeDescriptionTextAttributes)
        
        let minsNumLabel = UILabel(forAutoLayout: ())
        self.minsNumLabel = minsNumLabel
        
        let minsTextLabel = UILabel(forAutoLayout: ())
        minsTextLabel.attributedText = NSAttributedString(string: "мин", attributes: timeDescriptionTextAttributes)
        
        [minsTextLabel, minsNumLabel, hrsTextLabel, hrsNumLabel].forEach { [weak self] label in
            self?.contentView.addSubview(label)
        }
        
        minsTextLabel.autoPinEdge(toSuperviewEdge: .bottom, withInset: 16)
        
        minsTextLabel.autoPinEdge(toSuperviewEdge: .right, withInset: 16)
        minsNumLabel.autoPinEdge(.right, to: .left, of: minsTextLabel, withOffset: -4)
        
        hrsTextLabel.autoPinEdge(.right, to: .left, of: minsNumLabel, withOffset: -6)
        hrsNumLabel.autoPinEdge(.right, to: .left, of: hrsTextLabel, withOffset: -4)
        
        [minsNumLabel, hrsTextLabel, hrsNumLabel].forEach { label in
            label.autoAlignAxis(.horizontal, toSameAxisOf: minsTextLabel)
        }
        
        let attemptsNumLabel = UILabel(forAutoLayout: ())
        self.attemptsNumLabel = attemptsNumLabel
        
        let attemptsTextLabel = UILabel(forAutoLayout: ())
        self.attemptsTextLabel = attemptsTextLabel
        
        [attemptsTextLabel, attemptsNumLabel].forEach { [weak self] label in
            self?.contentView.addSubview(label)
        }
        
        attemptsTextLabel.autoPinEdge(.left, to: .right, of: attemptsNumLabel, withOffset: 6)
        attemptsNumLabel.autoPinEdge(toSuperviewEdge: .left, withInset: 16)
        
        [attemptsTextLabel, attemptsNumLabel].forEach { label in
            label.autoAlignAxis(.horizontal, toSameAxisOf: minsTextLabel)
        }
    }
    
    func configure(model: BookSessionsCellModel) {
        let style = NSMutableParagraphStyle()
        style.maximumLineHeight = SizeDependent.instance.convertPadding(36)
        
        let textSize = CGFloat(SizeDependent.instance.convertFont(36))
        
        let timeNumTextAttributes = [
            NSAttributedString.Key.foregroundColor : UIColor(rgb: 0xedaf97),
            NSAttributedString.Key.font : UIFont(name: "Avenir-Medium", size: textSize)!,
            NSAttributedString.Key.paragraphStyle: style,
            NSAttributedString.Key.baselineOffset: -8]
            as [NSAttributedString.Key : Any]
        
        let attemptsNumTextAttributes = [
            NSAttributedString.Key.foregroundColor : UIColor(rgb: 0x2f5870).withAlphaComponent(0.5),
            NSAttributedString.Key.font : UIFont(name: "Avenir-Medium", size: textSize)!,
            NSAttributedString.Key.paragraphStyle: style,
            NSAttributedString.Key.baselineOffset: -8]
            as [NSAttributedString.Key : Any]
        
        let styleSmall = NSMutableParagraphStyle()
        styleSmall.maximumLineHeight = SizeDependent.instance.convertPadding(20)
        let textSizeSmall = CGFloat(SizeDependent.instance.convertFont(18))
        let attemptsDescriptionTextAttributes = [
            NSAttributedString.Key.foregroundColor : UIColor(rgb: 0x2f5870).withAlphaComponent(0.5),
            NSAttributedString.Key.font : UIFont(name: "Avenir-Light", size: textSizeSmall)!,
            NSAttributedString.Key.paragraphStyle: styleSmall,
            NSAttributedString.Key.baselineOffset: -4]
            as [NSAttributedString.Key : Any]
        
        let titleTextAttributes = [
            NSAttributedString.Key.foregroundColor : UIColor(rgb: 0x2f5870),
            NSAttributedString.Key.font : UIFont(name: "Avenir-Medium", size: 14.0)!]
            as [NSAttributedString.Key : Any]
        
        let authorTextAttributes = [
            NSAttributedString.Key.foregroundColor : UIColor(rgb: 0x2f5870).withAlphaComponent(0.5),
            NSAttributedString.Key.font : UIFont(name: "Avenir-Light", size: 14.0)!]
            as [NSAttributedString.Key : Any]
        
        titleLabel?.attributedText = NSAttributedString(string: model.book.title, attributes: titleTextAttributes)
        authorLabel?.attributedText = NSAttributedString(string: model.book.author, attributes: authorTextAttributes)
        minsNumLabel?.attributedText = NSAttributedString(string: String((model.time / 60) % 60), attributes: timeNumTextAttributes)
        hrsNumLabel?.attributedText = NSAttributedString(string: String(model.time / 3600), attributes: timeNumTextAttributes)
        attemptsNumLabel?.attributedText = NSAttributedString(string: String(model.attempts), attributes: attemptsNumTextAttributes)
        attemptsTextLabel?.attributedText = NSAttributedString(string: PluralRule().getAttempts(count: model.attempts), attributes: attemptsDescriptionTextAttributes)
    }
}
