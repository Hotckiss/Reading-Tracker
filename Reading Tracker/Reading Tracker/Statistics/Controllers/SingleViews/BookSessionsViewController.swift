//
//  BookSessionsViewController.swift
//  Reading Tracker
//
//  Created by Andrei Kirilenko on 08/12/2018.
//  Copyright © 2018 Andrei Kirilenko. All rights reserved.
//

import Foundation
import UIKit

final class BookSessionsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    private var navBar: NavigationBar?
    private var bookCell: BookFilledCell?
    
    private var bookModel: BookModel
    private var sessionModels: [UploadSessionModel]
    
    init(model: BookModel, sessionModels: [UploadSessionModel]) {
        self.bookModel = model
        self.sessionModels = sessionModels
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
        
        navBar.configure(model: NavigationBarModel(title: "Записи о чтении",
                                                   backButtonText: "Назад",
                                                   onBackButtonPressed: ({ [weak self] in
                                                    self?.navigationController?.popViewController(animated: true)
                                                   })))
        navBar.backgroundColor = UIColor(rgb: 0x2f5870)
        
        view.addSubview(navBar)
        navBar.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .bottom)
        self.navBar = navBar
        
        let bookCell = BookFilledCell(frame: .zero)
        bookCell.layer.shadowColor = UIColor.black.cgColor
        bookCell.layer.shadowOpacity = 0.2
        bookCell.layer.shadowOffset = CGSize(width: 0.0, height: 3.0)
        view.addSubview(bookCell)
        bookCell.autoPinEdge(toSuperviewEdge: .left)
        bookCell.autoPinEdge(toSuperviewEdge: .right)
        bookCell.autoPinEdge(.top, to: .bottom, of: navBar)
        bookCell.configure(model: bookModel)
        self.bookCell = bookCell
        
        let tableView = UITableView(forAutoLayout: ())
        view.addSubview(tableView)
        tableView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 0, left: 0, bottom: bottomSpace, right: 0), excludingEdge: .top)
        tableView.autoPinEdge(.top, to: .bottom, of: bookCell)
        tableView.register(BookSessionTimesCell.self, forCellReuseIdentifier: "bookSessionCell")
        
        tableView.tableFooterView = UIView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .white
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.separatorColor = UIColor(rgb: 0x2f5870)
        
        view.bringSubviewToFront(bookCell)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sessionModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "bookSessionCell") as! BookSessionTimesCell
        cell.configure(model: sessionModels[indexPath.row])
        
        return cell
    }
}
