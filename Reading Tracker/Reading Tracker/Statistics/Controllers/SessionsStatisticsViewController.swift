//
//  SessionsStatisticsViewController.swift
//  Reading Tracker
//
//  Created by Andrei Kirilenko on 01/12/2018.
//  Copyright © 2018 Andrei Kirilenko. All rights reserved.
//

import Foundation
import UIKit
import Firebase

final class SessionsStatisticsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    private var spinner: SpinnerView?
    private var sessions: [UploadSessionModel] = []
    private var booksMap: [String : BookModel] = [:]
    private var indexOfLongestSession: Int = 0
    private var tableView: UITableView?
    private var tableViewHeightConstraint: NSLayoutConstraint?
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    func update(sessions: [UploadSessionModel], booksMap: [String : BookModel]) {
        guard !sessions.isEmpty else {
            return
        }
        
        self.sessions = sessions
        self.booksMap = booksMap
        for (index, session) in sessions.enumerated() {
            if session.time > sessions[indexOfLongestSession].time {
                indexOfLongestSession = index
            }
        }
        
        tableViewHeightConstraint?.constant = CGFloat(sessions.count * 118 + 2 * 42 + 118)
        tableView?.reloadData()
        
        //tableView?.frame.size = tableView?.contentSize ?? CGSize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .red
        
        let tableView = UITableView(forAutoLayout: ())
        view.addSubview(tableView)
        tableView.backgroundColor = .red
        tableView.autoPinEdgesToSuperviewEdges()
        tableView.register(SessionCell.self, forCellReuseIdentifier: "sessionCell")
        tableView.register(SectionCell.self, forCellReuseIdentifier: "sectionCell")
        
        let lineView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 1))
        lineView.backgroundColor = UIColor(rgb: 0x2f5870).withAlphaComponent(0.5)
        
        tableView.tableFooterView = lineView
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .white
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.separatorColor = UIColor(rgb: 0x2f5870)
        tableView.isScrollEnabled = false
        tableViewHeightConstraint = tableView.autoSetDimension(.height, toSize: 0)
        self.tableView = tableView
        
        setupSpinner()
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteRowAction = UITableViewRowAction(style: UITableViewRowAction.Style.default, title: "Удалить", handler: { [weak self] action, indexpath in
            //REMOVE
        })
        return [deleteRowAction]
    }
    
    private func setupSpinner() {
        let spinner = SpinnerView(frame: .zero)
        view.addSubview(spinner)
        
        view.bringSubviewToFront(spinner)
        spinner.autoPinEdgesToSuperviewEdges()
        self.spinner = spinner
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (section == 0) ? 1 : sessions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "sessionCell") as! SessionCell
        if indexPath.section == 0 {
            if let book = booksMap[sessions[indexOfLongestSession].bookId] {
                cell.configure(model: SessionCellModel(sessionInfo: sessions[indexOfLongestSession], book: book))
            }
        } else {
            if let book = booksMap[sessions[indexPath.row].bookId] {
                cell.configure(model: SessionCellModel(sessionInfo: sessions[indexPath.row], book: book))
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let session = sessions[indexPath.row]
        //onTapToStartSession?(book)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: "sectionCell") as! SectionCell
        cell.configure(text: (section == 0) ? "Самое продолжительное чтение" : "Все записи о чтении")
        return cell.contentView
    }
}

public struct SessionCellModel {
    var book: BookModel
    var sessionInfo: UploadSessionModel
    
    public init(sessionInfo: UploadSessionModel = UploadSessionModel(), book: BookModel = BookModel()) {
        self.book = book
        self.sessionInfo = sessionInfo
    }
}

private class SectionCell: UITableViewCell {
    private var titleLabel: UILabel?
    
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
        contentView.addSubview(titleLabel)
        contentView.backgroundColor = .white
        titleLabel.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 16, left: 16, bottom: 6, right: 16))
        self.titleLabel = titleLabel
        
        let lineView = UIView(frame: .zero)
        lineView.backgroundColor = UIColor(rgb: 0x2f5870).withAlphaComponent(0.5)
        
        contentView.addSubview(lineView)
        lineView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16), excludingEdge: .top)
        lineView.autoSetDimension(.height, toSize: 1)
    }
    
    func configure(text: String) {
        let style = NSMutableParagraphStyle()
        style.maximumLineHeight = 20
        style.minimumLineHeight = 20
        style.alignment = .right
        let titleTextAttributes = [
            NSAttributedString.Key.foregroundColor : UIColor(rgb: 0x2f5870).withAlphaComponent(0.5),
            NSAttributedString.Key.font : UIFont(name: "Avenir-Light", size: 14.0)!,
            NSAttributedString.Key.paragraphStyle: style]
            as [NSAttributedString.Key : Any]
        
        titleLabel?.attributedText = NSAttributedString(string: text, attributes: titleTextAttributes)
    }
}

private class SessionCell: UITableViewCell {
    private var model: SessionCellModel = SessionCellModel()
    private var dateLabel: UILabel?
    private var dayOfWeekLabel: UILabel?
    private var titleLabel: UILabel?
    private var authorLabel: UILabel?
    
    private var hrsNumLabel: UILabel?
    private var minsNumLabel: UILabel?
    
    private var commentView: UIImageView?
    private var placeView: UIImageView?
    private var moodView: UIImageView?
    
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
        addSubview(dateLabel)
        dateLabel.autoPinEdge(toSuperviewEdge: .left, withInset: 16)
        dateLabel.autoPinEdge(toSuperviewEdge: .top, withInset: 20)
        
        let dayOfWeekLabel = UILabel(forAutoLayout: ())
        dayOfWeekLabel.numberOfLines = 1
        addSubview(dayOfWeekLabel)
        dayOfWeekLabel.autoPinEdge(.left, to: .right, of: dateLabel, withOffset: 4)
        dayOfWeekLabel.autoAlignAxis(.horizontal, toSameAxisOf: dateLabel)
        
        let titleLabel = UILabel(forAutoLayout: ())
        titleLabel.numberOfLines = 0
        addSubview(titleLabel)
        titleLabel.autoPinEdge(toSuperviewEdge: .left, withInset: 16)
        titleLabel.autoPinEdge(toSuperviewEdge: .right, withInset: 16)
        titleLabel.autoPinEdge(.top, to: .bottom, of: dateLabel, withOffset: 16)
        
        let authorLabel = UILabel(forAutoLayout: ())
        authorLabel.numberOfLines = 0
        addSubview(authorLabel)
        authorLabel.autoPinEdge(toSuperviewEdge: .left, withInset: 16)
        authorLabel.autoPinEdge(toSuperviewEdge: .right, withInset: 16)
        authorLabel.autoPinEdge(.top, to: .bottom, of: titleLabel)
        authorLabel.autoPinEdge(toSuperviewEdge: .bottom, withInset: 16)
        self.dateLabel = dateLabel
        self.dayOfWeekLabel = dayOfWeekLabel
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
        hrsTextLabel.attributedText = NSAttributedString(string: "час", attributes: timeDescriptionTextAttributes)
        
        let minsNumLabel = UILabel(forAutoLayout: ())
        self.minsNumLabel = minsNumLabel
        
        let minsTextLabel = UILabel(forAutoLayout: ())
        minsTextLabel.attributedText = NSAttributedString(string: "мин", attributes: timeDescriptionTextAttributes)
        
        [minsTextLabel, minsNumLabel, hrsTextLabel, hrsNumLabel].forEach { [weak self] label in
            self?.addSubview(label)
        }
        
        minsTextLabel.autoPinEdge(toSuperviewEdge: .top, withInset: 24)
        
        minsTextLabel.autoPinEdge(toSuperviewEdge: .right, withInset: 16)
        minsNumLabel.autoPinEdge(.right, to: .left, of: minsTextLabel, withOffset: -4)
        
        hrsTextLabel.autoPinEdge(.right, to: .left, of: minsNumLabel, withOffset: -6)
        hrsNumLabel.autoPinEdge(.right, to: .left, of: hrsTextLabel, withOffset: -4)
        
        [minsNumLabel, hrsTextLabel, hrsNumLabel].forEach { label in
            label.autoAlignAxis(.horizontal, toSameAxisOf: minsTextLabel)
        }
    }
    
    func configure(model: SessionCellModel) {
        self.model = model
        
        let style = NSMutableParagraphStyle()
        style.maximumLineHeight = SizeDependent.instance.convertPadding(36)
        
        let textSize = CGFloat(SizeDependent.instance.convertFont(36))
        
        let timeNumTextAttributes = [
            NSAttributedString.Key.foregroundColor : UIColor(rgb: 0xedaf97),
            NSAttributedString.Key.font : UIFont(name: "Avenir-Medium", size: textSize)!,
            NSAttributedString.Key.paragraphStyle: style,
            NSAttributedString.Key.baselineOffset: -8]
            as [NSAttributedString.Key : Any]
        
        let dateTextAttributes = [
            NSAttributedString.Key.foregroundColor : UIColor(rgb: 0x2f5870),
            NSAttributedString.Key.font : UIFont(name: "Avenir-Medium", size: 20.0)!]
            as [NSAttributedString.Key : Any]
        
        let dayOfWeekTextAttributes = [
            NSAttributedString.Key.foregroundColor : UIColor(rgb: 0x2f5870).withAlphaComponent(0.5),
            NSAttributedString.Key.font : UIFont(name: "Avenir-Light", size: 14.0)!]
            as [NSAttributedString.Key : Any]
        
        let titleTextAttributes = [
            NSAttributedString.Key.foregroundColor : UIColor(rgb: 0x2f5870),
            NSAttributedString.Key.font : UIFont(name: "Avenir-Medium", size: 14.0)!]
            as [NSAttributedString.Key : Any]
        
        let authorTextAttributes = [
            NSAttributedString.Key.foregroundColor : UIColor(rgb: 0x2f5870).withAlphaComponent(0.5),
            NSAttributedString.Key.font : UIFont(name: "Avenir-Light", size: 14.0)!]
            as [NSAttributedString.Key : Any]
        
        dateLabel?.attributedText = NSAttributedString(string: format(model.sessionInfo.startTime), attributes: dateTextAttributes)
        dayOfWeekLabel?.attributedText = NSAttributedString(string: getDayOfWeek(model.sessionInfo.startTime), attributes: dayOfWeekTextAttributes)
        titleLabel?.attributedText = NSAttributedString(string: model.book.title, attributes: titleTextAttributes)
        authorLabel?.attributedText = NSAttributedString(string: model.book.author, attributes: authorTextAttributes)
        minsNumLabel?.attributedText = NSAttributedString(string: String((model.sessionInfo.time / 60) % 60), attributes: timeNumTextAttributes)
        hrsNumLabel?.attributedText = NSAttributedString(string: String(model.sessionInfo.time / 3600), attributes: timeNumTextAttributes)
        
        commentView?.removeFromSuperview()
        placeView?.removeFromSuperview()
        moodView?.removeFromSuperview()
        
        var lastView: UIImageView?
        
        if !model.sessionInfo.comment.isEmpty {
            let commentView = UIImageView(forAutoLayout: ())
            commentView.image = UIImage(named: "commentIcon")
            commentView.alpha = 0.5
            self.commentView = commentView
            addSubview(commentView)
            commentView.autoSetDimensions(to: CGSize(width: 16, height: 16))
            commentView.autoPinEdge(toSuperviewEdge: .right, withInset: 16)
            commentView.autoPinEdge(toSuperviewEdge: .bottom, withInset: 16)
            lastView = commentView
        }
        
        if model.sessionInfo.readPlace != .unknown {
            let placeView = UIImageView(forAutoLayout: ())
            placeView.image = UIImage(named: model.sessionInfo.readPlace.rawValue)
            placeView.alpha = 0.5
            self.placeView = placeView
            addSubview(placeView)
            placeView.autoPinEdge(toSuperviewEdge: .bottom, withInset: 16)
            placeView.autoSetDimensions(to: CGSize(width: 16, height: 16))
            
            if let last = lastView {
                placeView.autoPinEdge(.right, to: .left, of: last, withOffset: -8)
            } else {
                placeView.autoPinEdge(toSuperviewEdge: .right, withInset: 16)
            }
            
            lastView = placeView
        }
        
        if model.sessionInfo.mood != .unknown {
            let moodView = UIImageView(forAutoLayout: ())
            moodView.image = UIImage(named: model.sessionInfo.mood.rawValue)
            moodView.alpha = 0.5
            self.moodView = moodView
            addSubview(moodView)
            moodView.autoPinEdge(toSuperviewEdge: .bottom, withInset: 16)
            moodView.autoSetDimensions(to: CGSize(width: 16, height: 16))
            
            if let last = lastView {
                moodView.autoPinEdge(.right, to: .left, of: last, withOffset: -8)
            } else {
                moodView.autoPinEdge(toSuperviewEdge: .right, withInset: 16)
            }
            
            lastView = moodView
        }
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
