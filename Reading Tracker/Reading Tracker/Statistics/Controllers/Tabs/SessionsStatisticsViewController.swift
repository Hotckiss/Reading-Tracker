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
    
    func update(sessions: [UploadSessionModel], booksMap: [String : BookModel], interval: StatsInterval) {
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
        let dataIndex = (indexPath.section == 1 ? indexPath.row : indexOfLongestSession)
        
        let session = sessions[dataIndex]
        if let book = booksMap[sessions[dataIndex].bookId] {
            let vc = SingleSessionViewController(model: book, sessionModel: session)
            navigationController?.pushViewController(vc, animated: true)
        }
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
