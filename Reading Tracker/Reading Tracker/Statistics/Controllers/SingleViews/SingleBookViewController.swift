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
    
    private var freqLabel: UILabel?
    private var freqPlaceView: UIImageView?
    private var freqMoodView: UIImageView?
    
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
        
        let attemptsTextAttributesBig = [
            NSAttributedString.Key.foregroundColor : UIColor(rgb: 0x2f5870).withAlphaComponent(0.5),
            NSAttributedString.Key.font : UIFont(name: "Avenir-Medium", size: 48.0)!]
            as [NSAttributedString.Key : Any]
        
        let attemptsTextAttributesSmall = [
            NSAttributedString.Key.foregroundColor : UIColor(rgb: 0x2f5870).withAlphaComponent(0.5),
            NSAttributedString.Key.font : UIFont(name: "Avenir-Light", size: 24.0)!,
            NSAttributedString.Key.baselineOffset: 8]
            as [NSAttributedString.Key : Any]
        
        let attemptsString = PluralRule().formatAttempts(count: summary.attempts)
        
        let attemptsAttributed = NSMutableAttributedString(string: attemptsString, attributes: attemptsTextAttributesBig)
        let numberLenght = String(summary.attempts).count
        attemptsAttributed.addAttributes(attemptsTextAttributesSmall, range: NSRange(location: numberLenght, length: attemptsString.count - numberLenght))
        attemptsLabel?.attributedText = attemptsAttributed

        let pagesTextAttributesSmall = [
            NSAttributedString.Key.foregroundColor : UIColor(rgb: 0x2f5870),
            NSAttributedString.Key.font : UIFont(name: "Avenir-Light", size: 24.0)!]
            as [NSAttributedString.Key : Any]
        
        let pagesTextAttributesBig = [
            NSAttributedString.Key.foregroundColor : UIColor(rgb: 0x2f5870),
            NSAttributedString.Key.font : UIFont(name: "Avenir-Light", size: 48.0)!]
            as [NSAttributedString.Key : Any]
        
        let pagesCount = (summary.maxPage ?? 0) - (summary.minPage ?? 0)
        let pagesString = PluralRule().formatPages(count: pagesCount) + ", " +
            String(summary.minPage ?? 0) +
            " \u{2013} " +
            String(summary.maxPage ?? 0)
        
        let pagesAttributed = NSMutableAttributedString(string: pagesString, attributes: pagesTextAttributesSmall)
        pagesAttributed.addAttributes(pagesTextAttributesBig, range: NSRange(location: 0, length: String(pagesCount).count))
        
        pagesLabel?.attributedText = pagesAttributed
        
        [freqLabel, freqPlaceView, freqMoodView].forEach { label in
            label?.removeFromSuperview()
        }
        
        if summary.moodsCounts.count + summary.placesCounts.count > 0,
            let pagesView = pagesLabel {
            if !summary.moodsCounts.isEmpty {
                var maxMoodCount = -1
                var maxMoodKey = ""
                
                for mood in Mood.all {
                    if let cnt = summary.moodsCounts[mood.rawValue],
                        cnt >= maxMoodCount {
                        maxMoodCount = cnt
                        maxMoodKey = mood.rawValue
                    }
                }
                
                let freqMoodView = UIImageView(image: UIImage(named: maxMoodKey))
                contentView.addSubview(freqMoodView)
                freqMoodView.autoPinEdge(toSuperviewEdge: .left, withInset: 16)
                freqMoodView.autoPinEdge(.top, to: .bottom, of: pagesView, withOffset: 16)
                self.freqMoodView = freqMoodView
            }
            
            if !summary.placesCounts.isEmpty {
                var maxPlaceCount = -1
                var maxPlaceKey = ""
                
                for place in ReadPlace.all {
                    if let cnt = summary.placesCounts[place.rawValue],
                        cnt >= maxPlaceCount {
                        maxPlaceCount = cnt
                        maxPlaceKey = place.rawValue
                    }
                }
                
                let freqPlaceView = UIImageView(image: UIImage(named: maxPlaceKey))
                contentView.addSubview(freqPlaceView)
                
                if let freqMood = freqMoodView {
                    freqPlaceView.autoAlignAxis(.horizontal, toSameAxisOf: freqMood)
                    freqPlaceView.autoPinEdge(.left, to: .right, of: freqMood, withOffset: 12)
                } else {
                    freqPlaceView.autoPinEdge(toSuperviewEdge: .left, withInset: 16)
                    freqPlaceView.autoPinEdge(.top, to: .bottom, of: pagesView, withOffset: 16)
                }
                
                self.freqPlaceView = freqPlaceView
            }
            
            let freqLabel = UILabel(forAutoLayout: ())
            freqLabel.attributedText = NSAttributedString(string: "чаще всего", attributes: pagesTextAttributesSmall)
            self.freqLabel = freqLabel
            
            
            if let placeV = freqPlaceView {
                contentView.addSubview(freqLabel)
                freqLabel.autoPinEdge(.bottom, to: .bottom, of: placeV)
                freqLabel.autoPinEdge(.left, to: .right, of: placeV, withOffset: 12)
            } else if let moodV = freqMoodView {
                contentView.addSubview(freqLabel)
                freqLabel.autoPinEdge(.bottom, to: .bottom, of: moodV)
                freqLabel.autoPinEdge(.left, to: .right, of: moodV, withOffset: 12)
            }
        }
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
