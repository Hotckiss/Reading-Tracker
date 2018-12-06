//
//  SingleSessionViewController.swift
//  Reading Tracker
//
//  Created by Andrei Kirilenko on 06/12/2018.
//  Copyright © 2018 Andrei Kirilenko. All rights reserved.
//

import Foundation
import UIKit

final class SingleSessionViewController: UIViewController {
    private var spinner: SpinnerView?
    private var navBar: NavigationBar?
    private var bookCell: BookFilledCell?
    private var bookModel: BookModel
    private var sessionModel: UploadSessionModel
    
    private var hrsNumLabel: UILabel?
    private var minsNumLabel: UILabel?
    
    private var startTimeLabel: UILabel?
    private var finishTimeLabel: UILabel?
    
    private var pagesLabel: UILabel?
    
    init(model: BookModel, sessionModel: UploadSessionModel) {
        self.bookModel = model
        self.sessionModel = sessionModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        var bottomSpace: CGFloat = 49
        if #available(iOS 11.0, *) {
            bottomSpace += UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
        }
        
        let navBar = NavigationBar()
        
        navBar.configure(model: NavigationBarModel(title: "Запись о чтении",
                                                   backButtonText: "Назад",
                                                   frontButtonText: "",
                                                   onBackButtonPressed: ({ [weak self] in
                                                    self?.navigationController?.popViewController(animated: true)
                                                   })))
        navBar.backgroundColor = UIColor(rgb: 0x2f5870)
        
        view.addSubview(navBar)
        navBar.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .bottom)
        self.navBar = navBar
        
        let bookCell = BookFilledCell(frame: .zero)
        view.addSubview(bookCell)
        bookCell.autoPinEdge(toSuperviewEdge: .left)
        bookCell.autoPinEdge(toSuperviewEdge: .right)
        bookCell.autoPinEdge(.top, to: .bottom, of: navBar)
        bookCell.configure(model: bookModel)
        self.bookCell = bookCell
        
        let lineView = UIView(frame: .zero)
        lineView.backgroundColor = UIColor(rgb: 0x2f5870).withAlphaComponent(0.5)
        
        view.addSubview(lineView)
        lineView.autoPinEdge(toSuperviewEdge: .left)
        lineView.autoPinEdge(toSuperviewEdge: .right)
        lineView.autoPinEdge(.top, to: .bottom, of: bookCell)
        lineView.autoSetDimension(.height, toSize: 1)
        
        let dateLabel = UILabel(forAutoLayout: ())
        dateLabel.numberOfLines = 1
        view.addSubview(dateLabel)
        dateLabel.autoPinEdge(toSuperviewEdge: .left, withInset: 16)
        dateLabel.autoPinEdge(.top, to: .bottom, of: lineView, withOffset: 20)
        
        let dayOfWeekLabel = UILabel(forAutoLayout: ())
        dayOfWeekLabel.numberOfLines = 1
        view.addSubview(dayOfWeekLabel)
        dayOfWeekLabel.autoPinEdge(.left, to: .right, of: dateLabel, withOffset: 8)
        dayOfWeekLabel.autoAlignAxis(.horizontal, toSameAxisOf: dateLabel)
        
        let dateTextAttributes = [
            NSAttributedString.Key.foregroundColor : UIColor(rgb: 0x2f5870),
            NSAttributedString.Key.font : UIFont(name: "Avenir-Medium", size: 20.0)!]
            as [NSAttributedString.Key : Any]
        
        let dayOfWeekTextAttributes = [
            NSAttributedString.Key.foregroundColor : UIColor(rgb: 0x2f5870).withAlphaComponent(0.5),
            NSAttributedString.Key.font : UIFont(name: "Avenir-Light", size: 14.0)!]
            as [NSAttributedString.Key : Any]
        
        dateLabel.attributedText = NSAttributedString(string: format(sessionModel.startTime), attributes: dateTextAttributes)
        dayOfWeekLabel.attributedText = NSAttributedString(string: getDayOfWeek(sessionModel.startTime), attributes: dayOfWeekTextAttributes)
        
        let timeDescriptionTextAttributes = [
            NSAttributedString.Key.foregroundColor : UIColor(rgb: 0xedaf97),
            NSAttributedString.Key.font : UIFont(name: "Avenir-Light", size: 24.0)!,
            NSAttributedString.Key.baselineOffset: 2]
            as [NSAttributedString.Key : Any]
        
        let hrsNumLabel = UILabel(forAutoLayout: ())
        self.hrsNumLabel = hrsNumLabel
        
        let hrsTextLabel = UILabel(forAutoLayout: ())
        hrsTextLabel.attributedText = NSAttributedString(string: "час", attributes: timeDescriptionTextAttributes)
        
        let minsNumLabel = UILabel(forAutoLayout: ())
        self.minsNumLabel = minsNumLabel
        
        let minsTextLabel = UILabel(forAutoLayout: ())
        minsTextLabel.attributedText = NSAttributedString(string: "мин", attributes: timeDescriptionTextAttributes)
        
        [minsTextLabel, minsNumLabel, hrsTextLabel, hrsNumLabel].forEach { [weak self] label in
            self?.view.addSubview(label)
        }
        
        hrsNumLabel.autoPinEdge(toSuperviewEdge: .left, withInset: 16)
        hrsNumLabel.autoPinEdge(.top, to: .bottom, of: dateLabel, withOffset: 16)
        hrsTextLabel.autoPinEdge(.left, to: .right, of: hrsNumLabel, withOffset: 4)
        minsNumLabel.autoPinEdge(.left, to: .right, of: hrsTextLabel, withOffset: 6)
        minsTextLabel.autoPinEdge(.left, to: .right, of: minsNumLabel, withOffset: 4)
        [minsNumLabel, hrsTextLabel, minsTextLabel].forEach { label in
            label.autoAlignAxis(.horizontal, toSameAxisOf: hrsNumLabel)
        }
        
        let startTimeLabel = UILabel(forAutoLayout: ())
        self.startTimeLabel = startTimeLabel
        
        view.addSubview(startTimeLabel)
        startTimeLabel.autoPinEdge(toSuperviewEdge: .left, withInset: 16)
        startTimeLabel.autoPinEdge(.top, to: .bottom, of: hrsNumLabel, withOffset: 16)
        
        let separatorLabel = UILabel(forAutoLayout: ())
        
        let separatorTextAttributesBig = [
            NSAttributedString.Key.foregroundColor : UIColor(rgb: 0x2f5870).withAlphaComponent(0.5),
            NSAttributedString.Key.font : UIFont(name: "Avenir-Light", size: 24.0)!,
            NSAttributedString.Key.baselineOffset: 2]
            as [NSAttributedString.Key : Any]
        
        separatorLabel.attributedText = NSAttributedString(string: "\u{2013}", attributes: separatorTextAttributesBig)
        view.addSubview(separatorLabel)
        separatorLabel.autoPinEdge(.left, to: .right, of: startTimeLabel, withOffset: 4)
        separatorLabel.autoAlignAxis(.horizontal, toSameAxisOf: startTimeLabel)
        
        let finishTimeLabel = UILabel(forAutoLayout: ())
        self.finishTimeLabel = finishTimeLabel
        
        view.addSubview(finishTimeLabel)
        finishTimeLabel.autoPinEdge(.left, to: .right, of: separatorLabel, withOffset: 4)
        finishTimeLabel.autoAlignAxis(.horizontal, toSameAxisOf: startTimeLabel)
        
        let pagesLabel = UILabel(forAutoLayout: ())
        self.pagesLabel = pagesLabel
        
        view.addSubview(pagesLabel)
        pagesLabel.autoPinEdge(toSuperviewEdge: .left, withInset: 16)
        pagesLabel.autoPinEdge(.top, to: .bottom, of: startTimeLabel, withOffset: 16)
        
        configure(sessionModel: sessionModel)
        setupSpinner()
    }
    
    func configure(sessionModel: UploadSessionModel) {
        let style = NSMutableParagraphStyle()
        style.maximumLineHeight = 48
        
        let timeNumTextAttributes = [
            NSAttributedString.Key.foregroundColor : UIColor(rgb: 0xedaf97),
            NSAttributedString.Key.font : UIFont(name: "Avenir-Medium", size: 48.0)!,
            NSAttributedString.Key.paragraphStyle: style,
            NSAttributedString.Key.baselineOffset: -8]
            as [NSAttributedString.Key : Any]
        
        minsNumLabel?.attributedText = NSAttributedString(string: String((sessionModel.time / 60) % 60), attributes: timeNumTextAttributes)
        hrsNumLabel?.attributedText = NSAttributedString(string: String(sessionModel.time / 3600), attributes: timeNumTextAttributes)
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "HH:mm"
        
        let textAttributesBig = [
            NSAttributedString.Key.foregroundColor : UIColor(rgb: 0x2f5870),
            NSAttributedString.Key.font : UIFont(name: "Avenir-Medium", size: 48.0)!]
            as [NSAttributedString.Key : Any]
        
        let textAttributesSmall = [
            NSAttributedString.Key.foregroundColor : UIColor(rgb: 0x2f5870),
            NSAttributedString.Key.font : UIFont(name: "Avenir-Light", size: 24.0)!,
            NSAttributedString.Key.baselineOffset: 8]
            as [NSAttributedString.Key : Any]
        
        let startTimeString = formatter.string(from: sessionModel.startTime)
        let finishTimeString = formatter.string(from: Calendar.current.date(byAdding: .second, value: sessionModel.time, to: sessionModel.startTime)!)
        
        let startTimeAttributed = NSMutableAttributedString(string: startTimeString, attributes: textAttributesBig)
        startTimeAttributed.addAttributes(textAttributesSmall, range: NSRange(location: 2, length: 3))
        startTimeLabel?.attributedText = startTimeAttributed
        
        let finishTimeAttributed = NSMutableAttributedString(string: finishTimeString, attributes: textAttributesBig)
        finishTimeAttributed.addAttributes(textAttributesSmall, range: NSRange(location: 2, length: 3))
        finishTimeLabel?.attributedText = finishTimeAttributed
        
        let pagesTextAttributesSmall = [
            NSAttributedString.Key.foregroundColor : UIColor(rgb: 0x2f5870),
            NSAttributedString.Key.font : UIFont(name: "Avenir-Light", size: 24.0)!]
            as [NSAttributedString.Key : Any]
        
        let pagesCount = sessionModel.finishPage - sessionModel.startPage
        let pagesString = PluralRule().formatPages(count: pagesCount) + ", " +
            String(sessionModel.startPage) +
            " \u{2013} " +
            String(sessionModel.finishPage)
        
        pagesLabel?.attributedText = NSAttributedString(string: pagesString, attributes: pagesTextAttributesSmall)
    }
    
    private func setupSpinner() {
        let spinner = SpinnerView(frame: .zero)
        view.addSubview(spinner)
        
        view.bringSubviewToFront(spinner)
        spinner.autoPinEdgesToSuperviewEdges()
        self.spinner = spinner
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
        return SingleSessionViewController.weedDayMap[weekDay]!
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
