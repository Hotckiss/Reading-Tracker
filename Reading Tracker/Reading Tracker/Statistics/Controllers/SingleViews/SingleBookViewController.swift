//
//  SingleBookViewController.swift
//  Reading Tracker
//
//  Created by Andrei Kirilenko on 08/12/2018.
//  Copyright © 2018 Andrei Kirilenko. All rights reserved.
//

import Foundation
import UIKit

final class SingleBookViewController: UIViewController {
    private var contentView: UIView!
    private var scrollView: UIScrollView!
    private var spinner: SpinnerView?
    private var navBar: NavigationBar?
    private var bookCell: BookFilledCell?
    private var bookModel: BookModel
    private var sessionModels: [UploadSessionModel]
    private var summary: SessionsSummModel
    
    private var hrsNumLabel: UILabel?
    private var minsNumLabel: UILabel?
    
    private var attemptsLabel: UILabel?
    
    private var pagesLabel: UILabel?
    private var placeView: UIImageView?
    private var moodView: UIImageView?
    
    init(model: BookModel, sessionModels: [UploadSessionModel], summary: SessionsSummModel) {
        self.bookModel = model
        self.sessionModels = sessionModels
        self.summary = summary
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
        
        navBar.configure(model: NavigationBarModel(title: "Статистика по книге",
                                                   backButtonText: "Назад",
                                                   frontButtonText: "",
                                                   onBackButtonPressed: ({ [weak self] in
                                                    self?.navigationController?.popViewController(animated: true)
                                                   })))
        navBar.backgroundColor = UIColor(rgb: 0x2f5870)
        
        view.addSubview(navBar)
        navBar.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .bottom)
        self.navBar = navBar
        
        let scrollView = UIScrollView(frame: .zero)
        scrollView.showsVerticalScrollIndicator = true
        scrollView.alwaysBounceVertical = true
        view.addSubview(scrollView)
        scrollView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 0, left: 0, bottom: bottomSpace, right: 0), excludingEdge: .top)
        scrollView.autoPinEdge(.top, to: .bottom, of: navBar)
        self.scrollView = scrollView
        
        let contentView = UIView(frame: .zero)
        scrollView.addSubview(contentView)
        contentView.autoMatch(.width, to: .width, of: scrollView)
        self.contentView = contentView
        
        let bookCell = BookFilledCell(frame: .zero)
        contentView.addSubview(bookCell)
        bookCell.autoPinEdge(toSuperviewEdge: .left)
        bookCell.autoPinEdge(toSuperviewEdge: .right)
        bookCell.autoPinEdge(toSuperviewEdge: .top)
        bookCell.autoMatch(.width, to: .width, of: contentView)
        bookCell.configure(model: bookModel)
        self.bookCell = bookCell
        
        let lineView = UIView(frame: .zero)
        lineView.backgroundColor = UIColor(rgb: 0x2f5870).withAlphaComponent(0.5)
        
        contentView.addSubview(lineView)
        lineView.autoPinEdge(toSuperviewEdge: .left)
        lineView.autoPinEdge(toSuperviewEdge: .right)
        lineView.autoPinEdge(.top, to: .bottom, of: bookCell)
        lineView.autoMatch(.width, to: .width, of: contentView)
        lineView.autoSetDimension(.height, toSize: 1)
        
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
            self?.contentView.addSubview(label)
        }
        
        hrsNumLabel.autoPinEdge(toSuperviewEdge: .left, withInset: 16)
        hrsNumLabel.autoPinEdge(.top, to: .bottom, of: lineView, withOffset: 16)
        hrsTextLabel.autoPinEdge(.left, to: .right, of: hrsNumLabel, withOffset: 4)
        minsNumLabel.autoPinEdge(.left, to: .right, of: hrsTextLabel, withOffset: 6)
        minsTextLabel.autoPinEdge(.left, to: .right, of: minsNumLabel, withOffset: 4)
        [minsNumLabel, hrsTextLabel, minsTextLabel].forEach { label in
            label.autoAlignAxis(.horizontal, toSameAxisOf: hrsNumLabel)
        }
        
        let attemptsLabel = UILabel(forAutoLayout: ())
        self.attemptsLabel = attemptsLabel
        
        contentView.addSubview(attemptsLabel)
        attemptsLabel.autoPinEdge(toSuperviewEdge: .left, withInset: 16)
        attemptsLabel.autoPinEdge(.top, to: .bottom, of: hrsNumLabel, withOffset: 16)
        
        let pagesLabel = UILabel(forAutoLayout: ())
        self.pagesLabel = pagesLabel
        
        contentView.addSubview(pagesLabel)
        pagesLabel.autoPinEdge(toSuperviewEdge: .left, withInset: 16)
        pagesLabel.autoPinEdge(.top, to: .bottom, of: attemptsLabel, withOffset: 16)
        
        configure(summary: summary)
        setupSpinner()
    }
    
    func configure(summary: SessionsSummModel) {
        let style = NSMutableParagraphStyle()
        style.maximumLineHeight = 48
        
        let timeNumTextAttributes = [
            NSAttributedString.Key.foregroundColor : UIColor(rgb: 0xedaf97),
            NSAttributedString.Key.font : UIFont(name: "Avenir-Medium", size: 48.0)!,
            NSAttributedString.Key.paragraphStyle: style,
            NSAttributedString.Key.baselineOffset: -8]
            as [NSAttributedString.Key : Any]
        
        minsNumLabel?.attributedText = NSAttributedString(string: String((summary.totalTime / 60) % 60), attributes: timeNumTextAttributes)
        hrsNumLabel?.attributedText = NSAttributedString(string: String(summary.totalTime / 3600), attributes: timeNumTextAttributes)
        
        let textAttributesBig = [
            NSAttributedString.Key.foregroundColor : UIColor(rgb: 0x2f5870),
            NSAttributedString.Key.font : UIFont(name: "Avenir-Medium", size: 48.0)!]
            as [NSAttributedString.Key : Any]
        
        let textAttributesSmall = [
            NSAttributedString.Key.foregroundColor : UIColor(rgb: 0x2f5870),
            NSAttributedString.Key.font : UIFont(name: "Avenir-Light", size: 24.0)!,
            NSAttributedString.Key.baselineOffset: 8]
            as [NSAttributedString.Key : Any]
        
        /*let startTimeString = ""
        
        let startTimeAttributed = NSMutableAttributedString(string: startTimeString, attributes: textAttributesBig)
        startTimeAttributed.addAttributes(textAttributesSmall, range: NSRange(location: 2, length: 3))
        startTimeLabel?.attributedText = startTimeAttributed
        */
        let pagesTextAttributes = [
            NSAttributedString.Key.foregroundColor : UIColor(rgb: 0x2f5870),
            NSAttributedString.Key.font : UIFont(name: "Avenir-Light", size: 24.0)!]
            as [NSAttributedString.Key : Any]
        
        let pagesCount = (summary.maxPage ?? 0) - (summary.minPage ?? 0)
        let pagesString = PluralRule().formatPages(count: pagesCount) + ", " +
            String(summary.minPage ?? 0) +
            " \u{2013} " +
            String(summary.maxPage ?? 0)
        
        pagesLabel?.attributedText = NSAttributedString(string: pagesString, attributes: pagesTextAttributes)
        
        var lastView: UIImageView?
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.contentSize = contentView.bounds.size
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
