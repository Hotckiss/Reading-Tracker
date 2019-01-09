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
    var onRequestReload: ((UploadSessionModel) -> Void)?
    var onDelete: ((UploadSessionModel) -> Void)?
    
    private var spinner: SpinnerView?
    private var sessions: [UploadSessionModel] = []
    private var booksMap: [String : BookModel] = [:]
    private var indexOfLongestSession: Int = 0
    private var tableView: UITableView?
    private var tableViewHeightConstraint: NSLayoutConstraint?
    private var interval: StatsInterval = .allTime
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    func update(sessions: [UploadSessionModel], booksMap: [String : BookModel], interval: StatsInterval) {
        self.sessions = sessions.sorted {
            $0.startTime > $1.startTime
        }
        self.booksMap = booksMap
        self.interval = interval
        indexOfLongestSession = 0
        for (index, session) in self.sessions.enumerated() {
            if session.time > self.sessions[indexOfLongestSession].time {
                indexOfLongestSession = index
            }
        }
        
        tableViewHeightConstraint?.constant = sessions.isEmpty ? 0 : CGFloat(sessions.count * 110 + 2 * 42 + 110)
        tableView?.reloadData()
        
        //tableView?.frame.size = tableView?.contentSize ?? CGSize()
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
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 120
        tableViewHeightConstraint = tableView.autoSetDimension(.height, toSize: 0)
        self.tableView = tableView
        
        setupSpinner()
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteRowAction = UITableViewRowAction(style: UITableViewRowAction.Style.default, title: "Удалить", handler: { [weak self] action, indexpath in
            guard let strongSelf = self else {
                return
            }
            let session: UploadSessionModel
            if indexpath.section == 0 {
                session = strongSelf.sessions[strongSelf.indexOfLongestSession]
            } else {
                session = strongSelf.sessions[indexpath.row]
            }
            
            FirestoreManager.DBManager.removeSession(sessionId: session.sessionId)
            strongSelf.onDelete?(session)
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
            if !sessions.isEmpty,
                let book = booksMap[sessions[indexOfLongestSession].bookId] {
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
        let dataIndex = (indexPath.section == 1 ? indexPath.row : indexOfLongestSession)
        
        let session = sessions[dataIndex]
        if let book = booksMap[sessions[dataIndex].bookId] {
            let vc = SingleSessionViewController(model: book, sessionModel: session)
            vc.onEdited = { [weak self] session in
                self?.onRequestReload?(session)
            }
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 42.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: "sectionCell") as! SectionCell
        cell.configure(text: (section == 0) ? "Самое продолжительное чтение" : "Все записи о чтении")
        return cell.contentView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableViewHeightConstraint?.constant = sessions.isEmpty ? 0 : CGFloat(sessions.count * 110 + 2 * 42 + 110)
        tableView?.reloadData()
    }
}
