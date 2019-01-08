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
    private var contentView: UIView!
    private var scrollView: UIScrollView!
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
    
    private var commentView: UIImageView?
    private var placeView: UIImageView?
    private var moodView: UIImageView?
    
    private var commentLabel: UILabel?
    
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
                                                   }), onFrontButtonPressed: ({ [weak self] in
                                                    //TODO: --
                                                    self?.showEditDialog()
                                                   })))
        navBar.setFrontButtonImage(image: UIImage(named: "vdots"))
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
        lineView.autoPinEdge(toSuperviewEdge: .left)
        lineView.autoPinEdge(toSuperviewEdge: .right)
        lineView.autoPinEdge(.top, to: .bottom, of: bookCell)
        lineView.autoMatch(.width, to: .width, of: contentView)
        lineView.autoSetDimension(.height, toSize: 1)
        
        let dateLabel = UILabel(forAutoLayout: ())
        dateLabel.numberOfLines = 1
        contentView.addSubview(dateLabel)
        dateLabel.autoPinEdge(toSuperviewEdge: .left, withInset: 16)
        dateLabel.autoPinEdge(.top, to: .bottom, of: lineView, withOffset: 20)
        
        let dayOfWeekLabel = UILabel(forAutoLayout: ())
        dayOfWeekLabel.numberOfLines = 1
        contentView.addSubview(dayOfWeekLabel)
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
            self?.contentView.addSubview(label)
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
        
        contentView.addSubview(startTimeLabel)
        startTimeLabel.autoPinEdge(toSuperviewEdge: .left, withInset: 16)
        startTimeLabel.autoPinEdge(.top, to: .bottom, of: hrsNumLabel, withOffset: 16)
        
        let separatorLabel = UILabel(forAutoLayout: ())
        
        let separatorTextAttributesBig = [
            NSAttributedString.Key.foregroundColor : UIColor(rgb: 0x2f5870).withAlphaComponent(0.5),
            NSAttributedString.Key.font : UIFont(name: "Avenir-Light", size: 24.0)!,
            NSAttributedString.Key.baselineOffset: 2]
            as [NSAttributedString.Key : Any]
        
        separatorLabel.attributedText = NSAttributedString(string: " \u{2013} ", attributes: separatorTextAttributesBig)
        contentView.addSubview(separatorLabel)
        separatorLabel.autoPinEdge(.left, to: .right, of: startTimeLabel, withOffset: 4)
        separatorLabel.autoAlignAxis(.horizontal, toSameAxisOf: startTimeLabel)
        
        let finishTimeLabel = UILabel(forAutoLayout: ())
        self.finishTimeLabel = finishTimeLabel
        
        contentView.addSubview(finishTimeLabel)
        finishTimeLabel.autoPinEdge(.left, to: .right, of: separatorLabel, withOffset: 4)
        finishTimeLabel.autoAlignAxis(.horizontal, toSameAxisOf: startTimeLabel)
        
        let pagesLabel = UILabel(forAutoLayout: ())
        self.pagesLabel = pagesLabel
        
        contentView.addSubview(pagesLabel)
        pagesLabel.autoPinEdge(toSuperviewEdge: .left, withInset: 16)
        pagesLabel.autoPinEdge(.top, to: .bottom, of: startTimeLabel, withOffset: 16)
        
        configure(sessionModel: sessionModel)
        setupSpinner()
    }
    
    private func showEditDialog() {
        let title = "Запись о чтении"
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Изменить время", style: .default, handler: ({ [weak self] _ in
            guard let strongSelf = self else {
                return
            }
            let vc = EditSessionTimeViewController()
            vc.configure(book: strongSelf.bookModel, startDate: strongSelf.sessionModel.startTime, finishDate: strongSelf.sessionModel.finishTime)
            self?.navigationController?.pushViewController(vc, animated: true)
        })))
        
        alert.addAction(UIAlertAction(title: "Изменить оценку", style: .default, handler: ({ [weak self] _ in
        })))
        
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
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
        formatter.dateFormat = "HH : mm"
        
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
        let finishTimeString = formatter.string(from: sessionModel.finishTime)
        
        let startTimeAttributed = NSMutableAttributedString(string: startTimeString, attributes: textAttributesBig)
        startTimeAttributed.addAttributes(textAttributesSmall, range: NSRange(location: 2, length: 3))
        startTimeLabel?.attributedText = startTimeAttributed
        
        let finishTimeAttributed = NSMutableAttributedString(string: finishTimeString, attributes: textAttributesBig)
        finishTimeAttributed.addAttributes(textAttributesSmall, range: NSRange(location: 2, length: 3))
        finishTimeLabel?.attributedText = finishTimeAttributed
        
        let pagesTextAttributes = [
            NSAttributedString.Key.foregroundColor : UIColor(rgb: 0x2f5870),
            NSAttributedString.Key.font : UIFont(name: "Avenir-Light", size: 24.0)!]
            as [NSAttributedString.Key : Any]
        
        let pagesCount = sessionModel.finishPage - sessionModel.startPage
        let pagesString = PluralRule().formatPages(count: pagesCount) + ", " +
            String(sessionModel.startPage) +
            " \u{2013} " +
            String(sessionModel.finishPage)
        
        pagesLabel?.attributedText = NSAttributedString(string: pagesString, attributes: pagesTextAttributes)
        
        var lastView: UIImageView?
        
        if let pagesView = pagesLabel {
            commentView?.removeFromSuperview()
            placeView?.removeFromSuperview()
            moodView?.removeFromSuperview()
            
            if sessionModel.mood != .unknown {
                let moodView = UIImageView(forAutoLayout: ())
                moodView.image = UIImage(named: sessionModel.mood.rawValue)
                self.moodView = moodView
                contentView.addSubview(moodView)
                moodView.autoPinEdge(.top, to: .bottom, of: pagesView, withOffset: 32)
                moodView.autoSetDimensions(to: CGSize(width: 32, height: 32))
                
                if let last = lastView {
                    moodView.autoPinEdge(.left, to: .right, of: last, withOffset: 16)
                } else {
                    moodView.autoPinEdge(toSuperviewEdge: .left, withInset: 16)
                }
                
                lastView = moodView
            }
            
            if sessionModel.readPlace != .unknown {
                let placeView = UIImageView(forAutoLayout: ())
                placeView.image = UIImage(named: sessionModel.readPlace.rawValue)
                self.placeView = placeView
                contentView.addSubview(placeView)
                placeView.autoPinEdge(.top, to: .bottom, of: pagesView, withOffset: 32)
                placeView.autoSetDimensions(to: CGSize(width: 32, height: 32))
                
                if let last = lastView {
                    placeView.autoPinEdge(.left, to: .right, of: last, withOffset: 16)
                } else {
                    placeView.autoPinEdge(toSuperviewEdge: .left, withInset: 16)
                }
                
                lastView = placeView
            }
            
            if !sessionModel.comment.isEmpty {
                let commentView = UIImageView(forAutoLayout: ())
                commentView.image = UIImage(named: "commentIcon")
                self.commentView = commentView
                contentView.addSubview(commentView)
                commentView.autoPinEdge(.top, to: .bottom, of: pagesView, withOffset: 32)
                commentView.autoSetDimensions(to: CGSize(width: 32, height: 32))
                
                if let last = lastView {
                    commentView.autoPinEdge(.left, to: .right, of: last, withOffset: 16)
                } else {
                    commentView.autoPinEdge(toSuperviewEdge: .left, withInset: 16)
                }
                
                self.commentLabel?.removeFromSuperview()
                
                let commentLabel = UILabel(forAutoLayout: ())
                commentLabel.numberOfLines = 0
                self.commentLabel = commentLabel
                contentView.addSubview(commentLabel)
                commentLabel.autoPinEdge(.top, to: .bottom, of: commentView, withOffset: 16)
                commentLabel.autoPinEdge(toSuperviewEdge: .left, withInset: 16)
                commentLabel.autoPinEdge(toSuperviewEdge: .right, withInset: 16)
                commentLabel.autoPinEdge(toSuperviewEdge: .bottom, withInset: 16)
                
                commentLabel.attributedText = NSAttributedString(string: sessionModel.comment, attributes: pagesTextAttributes)
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
