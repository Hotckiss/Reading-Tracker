//
//  BooksStatisticsViewController.swift
//  Reading Tracker
//
//  Created by Andrei Kirilenko on 01/12/2018.
//  Copyright © 2018 Andrei Kirilenko. All rights reserved.
//

import Foundation
import UIKit

import Foundation
import UIKit
import Firebase

struct SessionsSummModel {
    var totalTime: Int = 0
    var minPage: Int?
    var maxPage: Int?
    var attempts: Int = 0
    var moodsCounts: [String: Int] = [:]
    var placesCounts: [String: Int] = [:]
}

final class BooksStatisticsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    private var spinner: SpinnerView?
    private var groupedSessions: [String: [UploadSessionModel]] = [:]
    private var summSessions: [String: SessionsSummModel] = [:]
    private var keys: [String] = []
    private var booksMap: [String : BookModel] = [:]
    private var keyOfLongestBook: String = ""
    private var keyOfMostFrequentBook: String = ""
    private var tableView: UITableView?
    private var tableViewHeightConstraint: NSLayoutConstraint?
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    func update(sessions: [UploadSessionModel], booksMap: [String : BookModel], interval: StatsInterval) {
        let groupedSessions: [String: [UploadSessionModel]] = Dictionary(grouping: sessions) {
            $0.bookId
        }
        
        self.groupedSessions = groupedSessions
        self.booksMap = booksMap
        self.summSessions = [:]
        self.keyOfLongestBook = ""
        self.keyOfMostFrequentBook = ""
        for (key, sessionsArr) in groupedSessions {
            var ssm = SessionsSummModel()
            for session in sessionsArr {
                ssm.totalTime += session.time
                if ssm.minPage == nil {
                    ssm.minPage = session.startPage
                } else {
                    ssm.minPage = min(session.startPage, ssm.minPage!)
                }
                
                if ssm.maxPage == nil {
                    ssm.maxPage = session.finishPage
                } else {
                    ssm.maxPage = max(session.finishPage, ssm.maxPage!)
                }
                
                ssm.attempts += 1
                if session.mood != .unknown {
                    let currentValue = ssm.moodsCounts[session.mood.rawValue] ?? 0
                    ssm.moodsCounts[session.mood.rawValue] = currentValue + 1
                }
                if session.readPlace != .unknown {
                    let currentValue = ssm.placesCounts[session.readPlace.rawValue] ?? 0
                    ssm.placesCounts[session.readPlace.rawValue] = currentValue + 1
                }
            }
            summSessions[key] = ssm
        }
        var maxTimeCnt = 0
        var mostFreqCnt = 0
        
        for (key, ssm) in summSessions {
            if ssm.totalTime > maxTimeCnt {
                maxTimeCnt = ssm.totalTime
                keyOfLongestBook = key
            }
            
            if ssm.attempts > mostFreqCnt {
                mostFreqCnt = ssm.attempts
                keyOfMostFrequentBook = key
            }
        }
        
        keys = Array(summSessions.keys)
        tableViewHeightConstraint?.constant = CGFloat(groupedSessions.count * 118 + 3 * 42 + 118 * 2)
        tableView?.reloadData()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        let tableView = UITableView(forAutoLayout: ())
        view.addSubview(tableView)
        tableView.autoPinEdgesToSuperviewEdges()
        tableView.register(BookSessionsCell.self, forCellReuseIdentifier: "bookSessionsCell")
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
    
    private func setupSpinner() {
        let spinner = SpinnerView(frame: .zero)
        view.addSubview(spinner)
        
        view.bringSubviewToFront(spinner)
        spinner.autoPinEdgesToSuperviewEdges()
        self.spinner = spinner
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (section == 2) ? summSessions.count : 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "bookSessionsCell") as! BookSessionsCell
        if indexPath.section == 0 {
            if let book = booksMap[keyOfMostFrequentBook],
                let summ = summSessions[keyOfMostFrequentBook] {
                cell.configure(model: BookSessionsCellModel(book: book, attempts: summ.attempts, time: summ.totalTime))
            }
        } else if indexPath.section == 1 {
            if let book = booksMap[keyOfLongestBook],
                let summ = summSessions[keyOfLongestBook] {
                cell.configure(model: BookSessionsCellModel(book: book, attempts: summ.attempts, time: summ.totalTime))
            }
        } else {
            if let book = booksMap[keys[indexPath.row]],
                let summ = summSessions[keys[indexPath.row]] {
                cell.configure(model: BookSessionsCellModel(book: book, attempts: summ.attempts, time: summ.totalTime))
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 118.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let key: String
        switch indexPath.section {
        case 0:
            key = keyOfMostFrequentBook
        case 1:
            key = keyOfLongestBook
        default:
            key = keys[indexPath.row]
        }

        if let book = booksMap[key],
            let sessions = groupedSessions[key],
            let summary = summSessions[key] {
            let vc = SingleBookViewController(model: book, sessionModels: sessions, summary: summary)
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: "sectionCell") as! SectionCell
        let sectionText: String
        switch section {
        case 0:
            sectionText = "Больше всего подходов"
        case 1:
            sectionText = "Дольше всего читаете"
        default:
            sectionText = "И все остальное"
            
        }
        cell.configure(text: sectionText)
        return cell.contentView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableViewHeightConstraint?.constant = keys.isEmpty ? 0 : CGFloat(groupedSessions.count * 118 + 3 * 42 + 118 * 2)
        tableView?.reloadData()
    }
}
