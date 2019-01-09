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
    
    private var hrsNumLabel: UILabel!
    private var minsNumLabel: UILabel!
    
    private var attemptsLabel: UILabel!
    
    private var pagesLabel: UILabel?
    private var progressBar: UIProgressView?
    
    private var freqLabel: UILabel?
    private var freqPlaceView: UIImageView?
    private var freqMoodView: UIImageView?
    
    private var comButton: UIButton?
    private var recButton: UIButton?
    
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
                                                   onBackButtonPressed: ({ [weak self] in
                                                    self?.navigationController?.popViewController(animated: true)
                                                   })))
        navBar.backgroundColor = UIColor(rgb: 0x2f5870)
        navBar.setBackButtonImage(image: UIImage(named: "back"))
        view.addSubview(navBar)
        navBar.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .bottom)
        self.navBar = navBar
        
        let scrollView = UIScrollView(frame: .zero)
        scrollView.showsVerticalScrollIndicator = true
        scrollView.alwaysBounceVertical = true
        view.addSubview(scrollView)
        scrollView.isUserInteractionEnabled = true
        scrollView.isExclusiveTouch = true
        scrollView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 0, left: 0, bottom: bottomSpace, right: 0), excludingEdge: .top)
        scrollView.autoPinEdge(.top, to: .bottom, of: navBar)
        self.scrollView = scrollView
        
        let contentView = UIView(frame: .zero)
        scrollView.addSubview(contentView)
        contentView.autoMatch(.width, to: .width, of: scrollView)
        contentView.autoPinEdgesToSuperviewEdges()
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
        lineView.autoPinEdge(toSuperviewEdge: .left, withInset: 16)
        lineView.autoPinEdge(toSuperviewEdge: .right, withInset: 16)
        lineView.autoPinEdge(.top, to: .bottom, of: bookCell)
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
        
        configure(summary: summary, sessionModels: sessionModels)
        setupSpinner()
    }
    
    func configure(summary: SessionsSummModel, sessionModels: [UploadSessionModel]) {
        let style = NSMutableParagraphStyle()
        style.maximumLineHeight = 48
        
        let timeNumTextAttributes = [
            NSAttributedString.Key.foregroundColor : UIColor(rgb: 0xedaf97),
            NSAttributedString.Key.font : UIFont(name: "Avenir-Medium", size: 48.0)!,
            NSAttributedString.Key.paragraphStyle: style,
            NSAttributedString.Key.baselineOffset: -8]
            as [NSAttributedString.Key : Any]
        
        minsNumLabel.attributedText = NSAttributedString(string: String((summary.totalTime / 60) % 60), attributes: timeNumTextAttributes)
        hrsNumLabel.attributedText = NSAttributedString(string: String(summary.totalTime / 3600), attributes: timeNumTextAttributes)
        
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
        attemptsLabel.attributedText = attemptsAttributed

        let pagesTextAttributesSmall = [
            NSAttributedString.Key.foregroundColor : UIColor(rgb: 0x2f5870),
            NSAttributedString.Key.font : UIFont(name: "Avenir-Light", size: 24.0)!]
            as [NSAttributedString.Key : Any]
        
        let pagesTextAttributesBig = [
            NSAttributedString.Key.foregroundColor : UIColor(rgb: 0x2f5870),
            NSAttributedString.Key.font : UIFont(name: "Avenir-Light", size: 48.0)!]
            as [NSAttributedString.Key : Any]
        
        let pagesCount = (summary.maxPage ?? 0) - (summary.minPage ?? 0)
        let pagesProgress: String
        if summary.pagesCount > 0 {
            let percent: Int = Int(round(100.0 * Double(pagesCount) / Double(summary.pagesCount)))
            pagesProgress = "\(max(min(percent, 100), 0))%"
        } else {
            pagesProgress = String(summary.minPage ?? 0) +
                " \u{2013} " +
                String(summary.maxPage ?? 0)
        }
        let pagesString = PluralRule().formatPages(count: pagesCount) + ", " + pagesProgress
        
        let pagesAttributed = NSMutableAttributedString(string: pagesString, attributes: pagesTextAttributesSmall)
        pagesAttributed.addAttributes(pagesTextAttributesBig, range: NSRange(location: 0, length: String(pagesCount).count))
        
        pagesLabel?.attributedText = pagesAttributed
        
        progressBar?.removeFromSuperview()
        var lastViewOfPages: UIView? = pagesLabel
        if summary.pagesCount > 0,
           let pagesView = pagesLabel {
            let pagesCount = (summary.maxPage ?? 0) - (summary.minPage ?? 0)
            let percent: Float = Float(pagesCount) / Float(summary.pagesCount)
            let progressView = UIProgressView(forAutoLayout: ())
            progressView.tintColor = UIColor(rgb: 0x2f5870)
            progressView.trackTintColor = UIColor(rgb: 0x2f5870).withAlphaComponent(0.3)
            progressView.setProgress(percent, animated: true)
            contentView.addSubview(progressView)
            progressView.autoSetDimension(.height, toSize: 8)
            progressView.autoPinEdge(toSuperviewEdge: .left, withInset: 16)
            progressView.autoPinEdge(toSuperviewEdge: .right, withInset: 16)
            progressView.autoPinEdge(.top, to: .bottom, of: pagesView, withOffset: 4)
            self.progressBar = progressView
            lastViewOfPages = progressView
        }
        
        [freqLabel, freqPlaceView, freqMoodView].forEach { label in
            label?.removeFromSuperview()
        }
        
        if summary.moodsCounts.count + summary.placesCounts.count > 0,
            let pagesView = lastViewOfPages {
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
                freqMoodView.autoSetDimensions(to: CGSize(width: 32, height: 32))
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
                freqPlaceView.autoSetDimensions(to: CGSize(width: 32, height: 32))
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
        
        let endOfSectionView: UIView! = freqLabel ?? (lastViewOfPages ?? attemptsLabel)
        
        let lineView2 = UIView(frame: .zero)
        lineView2.backgroundColor = UIColor(rgb: 0x2f5870).withAlphaComponent(0.5)
        
        contentView.addSubview(lineView2)
        lineView2.autoPinEdge(toSuperviewEdge: .left, withInset: 16)
        lineView2.autoPinEdge(toSuperviewEdge: .right, withInset: 16)
        lineView2.autoPinEdge(.top, to: .bottom, of: endOfSectionView, withOffset: 32)
        lineView2.autoSetDimension(.height, toSize: 1)
        
        comButton?.removeFromSuperview()
        
        var commentsCount = 0
        for session in sessionModels {
            if !session.comment.isEmpty {
                commentsCount += 1
            }
        }
        
        let commButton = UIButton(forAutoLayout: ())
        contentView.addSubview(commButton)
        commButton.autoPinEdge(toSuperviewEdge: .left)
        commButton.autoPinEdge(toSuperviewEdge: .right)
        commButton.autoPinEdge(.top, to: .bottom, of: lineView2)
        commButton.autoSetDimension(.height, toSize: 90)
        self.comButton = commButton
        commButton.addTarget(self, action: #selector(commentsTap), for: .touchUpInside)
        
        let commButtonTextAttributes = [
            NSAttributedString.Key.foregroundColor : UIColor(rgb: 0x2f5870),
            NSAttributedString.Key.font : UIFont(name: "Avenir-Medium", size: 20.0)!]
            as [NSAttributedString.Key : Any]
        
        let commButtonTitle = UILabel(forAutoLayout: ())
        commButtonTitle.attributedText = NSAttributedString(string: "Комментарии", attributes: commButtonTextAttributes)
        commButton.addSubview(commButtonTitle)
        commButtonTitle.autoAlignAxis(toSuperviewAxis: .horizontal)
        commButtonTitle.autoPinEdge(toSuperviewEdge: .left, withInset: 16)
        
        if commentsCount > 0 {
            let cntLabel = UILabel(forAutoLayout: ())
            cntLabel.textAlignment = .center
            let cntTextAttributes = [
                NSAttributedString.Key.foregroundColor : UIColor(rgb: 0x2f5870).withAlphaComponent(0.5),
                NSAttributedString.Key.font : UIFont(name: "Avenir-Light", size: 14.0)!]
                as [NSAttributedString.Key : Any]
            
            cntLabel.attributedText = NSAttributedString(string: String(commentsCount), attributes: cntTextAttributes)
            commButton.addSubview(cntLabel)
            cntLabel.autoPinEdge(.left, to: .right, of: commButtonTitle, withOffset: 4)
            cntLabel.autoPinEdge(.bottom, to: .bottom, of: commButtonTitle, withOffset: -8)
        }
        
        let lineView3 = UIView(frame: .zero)
        lineView3.backgroundColor = UIColor(rgb: 0x2f5870).withAlphaComponent(0.5)
        
        contentView.addSubview(lineView3)
        lineView3.autoPinEdge(toSuperviewEdge: .left, withInset: 16)
        lineView3.autoPinEdge(toSuperviewEdge: .right, withInset: 16)
        lineView3.autoPinEdge(.top, to: .bottom, of: commButton)
        lineView3.autoSetDimension(.height, toSize: 1)
        
        recButton?.removeFromSuperview()
        let recordsButton = UIButton(forAutoLayout: ())
        recordsButton.addTarget(self, action: #selector(recordsTap), for: .touchUpInside)
        contentView.addSubview(recordsButton)
        recordsButton.autoPinEdge(toSuperviewEdge: .left)
        recordsButton.autoPinEdge(toSuperviewEdge: .right)
        recordsButton.autoPinEdge(.top, to: .bottom, of: lineView3)
        recordsButton.autoSetDimension(.height, toSize: 90)
        self.recButton = recordsButton
        
        let recordsButtonTitle = UILabel(forAutoLayout: ())
        recordsButtonTitle.attributedText = NSAttributedString(string: "Записи о чтении", attributes: commButtonTextAttributes)
        recordsButton.addSubview(recordsButtonTitle)
        recordsButtonTitle.autoAlignAxis(toSuperviewAxis: .horizontal)
        recordsButtonTitle.autoPinEdge(toSuperviewEdge: .left, withInset: 16)
        
        let lineView4 = UIView(frame: .zero)
        lineView4.backgroundColor = UIColor(rgb: 0x2f5870).withAlphaComponent(0.5)
        
        contentView.addSubview(lineView4)
        lineView4.autoPinEdge(toSuperviewEdge: .left, withInset: 16)
        lineView4.autoPinEdge(toSuperviewEdge: .right, withInset: 16)
        lineView4.autoPinEdge(.top, to: .bottom, of: recordsButton)
        lineView4.autoPinEdge(toSuperviewEdge: .bottom)
        lineView4.autoSetDimension(.height, toSize: 1)
    }
    
    @objc private func commentsTap() {
        let vc = BookCommentsViewController(model: bookModel, sessionModels: sessionModels)
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func recordsTap() {
        let vc = BookSessionsViewController(model: bookModel, sessionModels: sessionModels)
        
        navigationController?.pushViewController(vc, animated: true)
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
        return SingleBookViewController.weekDayMap[weekDay]!
    }
    
    static let weekDayMap: [Int: String] = [
        1: "воскресенье",
        2: "понедельник",
        3: "вторник",
        4: "среда",
        5: "четверг",
        6: "пятница",
        7: "суббота",
        ]
}
