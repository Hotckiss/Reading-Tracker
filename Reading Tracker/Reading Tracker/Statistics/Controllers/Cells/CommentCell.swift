//
//  CommentCell.swift
//  Reading Tracker
//
//  Created by Andrei Kirilenko on 08/12/2018.
//  Copyright © 2018 Andrei Kirilenko. All rights reserved.
//

import Foundation
import UIKit

class CommentCell: UITableViewCell {
    private var dateLabel: UILabel?
    private var dayOfWeekLabel: UILabel?
    private var pagesLabel: UILabel?
    private var commentLabel: UILabel?
    
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
        let dateLabel = UILabel(forAutoLayout: ())
        dateLabel.numberOfLines = 1
        contentView.addSubview(dateLabel)
        dateLabel.autoPinEdge(toSuperviewEdge: .left, withInset: 16)
        dateLabel.autoPinEdge(toSuperviewEdge: .top, withInset: 32)
        
        let dayOfWeekLabel = UILabel(forAutoLayout: ())
        dayOfWeekLabel.numberOfLines = 1
        contentView.addSubview(dayOfWeekLabel)
        dayOfWeekLabel.autoPinEdge(.left, to: .right, of: dateLabel, withOffset: 4)
        dayOfWeekLabel.autoAlignAxis(.horizontal, toSameAxisOf: dateLabel)
        self.dateLabel = dateLabel
        self.dayOfWeekLabel = dayOfWeekLabel
        
        let pagesLabel = UILabel(forAutoLayout: ())
        pagesLabel.numberOfLines = 1
        contentView.addSubview(pagesLabel)
        pagesLabel.autoPinEdge(toSuperviewEdge: .right, withInset: 16)
        pagesLabel.autoPinEdge(toSuperviewEdge: .top, withInset: 32)
        self.pagesLabel = pagesLabel
        
        let commentLabel = UILabel(forAutoLayout: ())
        commentLabel.numberOfLines = 0
        contentView.addSubview(commentLabel)
        commentLabel.autoPinEdge(toSuperviewEdge: .left, withInset: 16)
        commentLabel.autoPinEdge(toSuperviewEdge: .right, withInset: 16)
        commentLabel.autoPinEdge(.top, to: .bottom, of: dateLabel)
        commentLabel.autoPinEdge(toSuperviewEdge: .bottom)
        self.commentLabel = commentLabel
    }
    
    func configure(model: UploadSessionModel) {
        let dateTextAttributes = [
            NSAttributedString.Key.foregroundColor : UIColor(rgb: 0x2f5870),
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: 20, weight: .medium)]
            as [NSAttributedString.Key : Any]
        
        let dayOfWeekTextAttributes = [
            NSAttributedString.Key.foregroundColor : UIColor(rgb: 0x2f5870).withAlphaComponent(0.5),
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14, weight: .regular)]
            as [NSAttributedString.Key : Any]
        
        dateLabel?.attributedText = NSAttributedString(string: format(model.startTime), attributes: dateTextAttributes)
        dayOfWeekLabel?.attributedText = NSAttributedString(string: getDayOfWeek(model.startTime), attributes: dayOfWeekTextAttributes)
        
        let isSmallScreen = UIScreen.main.bounds.width == 320
        let pagesString = String(model.startPage) + "-" +
            String(model.finishPage) + (isSmallScreen ? " с." : " стр.")
        
        let pagesTextAttributes = [
            NSAttributedString.Key.foregroundColor : UIColor(rgb: 0x2f5870),
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: (isSmallScreen ? 16.0 : 20.0), weight: .regular)]
            as [NSAttributedString.Key : Any]
        
        pagesLabel?.attributedText = NSAttributedString(string: pagesString, attributes: pagesTextAttributes)
        
        commentLabel?.attributedText = NSAttributedString(string: model.comment, attributes: pagesTextAttributes)
    }
    
    public func format(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "d MMMM"
        return formatter.string(from: date)
    }
    
    func getDayOfWeek(_ date: Date) -> String {
        var cal = Calendar(identifier: .gregorian)
        cal.locale = Locale(identifier: "ru_RU")
        let weekDay = cal.component(.weekday, from: date)
        return SessionCell.weedDayMap[weekDay]!
    }
    
    static let weedDayMap: [Int: String] = [
        1: "воскресенье",
        2: "понедельник",
        3: "вторник",
        4: "среда",
        5: "четверг",
        6: "пятница",
        7: "суббота",
        ]
}
