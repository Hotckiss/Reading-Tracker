//
//  BookTextSearchResultViewController.swift
//  Reading Tracker
//
//  Created by Andrei Kirilenko on 07/01/2019.
//  Copyright © 2019 Andrei Kirilenko. All rights reserved.
//

import Foundation
import UIKit
import Firebase

final class BookTextSearchResultViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var onAdd: ((BookModel) -> Void)?
    private var navBar: NavigationBar?
    private var tableView: UITableView?
    private var books: [BookModelAPI] = []
    private var added: [Int: Bool] = [:]
    
    convenience init() {
        self.init(nibName: nil, bundle: nil)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?)   {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
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
        navBar.configure(model: NavigationBarModel(title: "Результаты поиска",
                                                   backButtonText: "Назад",
                                                   onBackButtonPressed: ({ [weak self] in
                                                    self?.navigationController?.popViewController(animated: true)
                                                   })
        ))
        navBar.backgroundColor = UIColor(rgb: 0x2f5870)
        view.addSubview(navBar)
        navBar.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .bottom)
        self.navBar = navBar
        
        let tableView = UITableView(forAutoLayout: ())
        view.addSubview(tableView)
        tableView.autoPinEdge(.top, to: .bottom, of: navBar)
        tableView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 0, left: 0, bottom: bottomSpace, right: 0), excludingEdge: .top)
        tableView.register(BookCellAPI.self, forCellReuseIdentifier: "bookCellAPI")
        tableView.tableFooterView = UIView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .white
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.separatorColor = UIColor(rgb: 0x2f5870)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 190
        self.tableView = tableView
    }
    
    func update(books: [BookModelAPI]) {
        self.books = books
        self.added = [:]
        tableView?.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return books.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "bookCellAPI") as! BookCellAPI
        cell.configure(model: books[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let isAdded = added[indexPath.row] ?? false
        if isAdded {
            return
        }
        
        let book = books[indexPath.row]
        let alert = UIAlertController(title: "Добавление книги", message: "Добавить книгу в библиотеку?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Да", style: .default, handler: ({ [weak self] _ in
            guard !isAdded else {
                return
            }
            
            let cell = self?.tableView?.cellForRow(at: indexPath) as? BookCellAPI
            cell?.markAsAdded()
            
            var model = BookModel(title: book.title ?? "",
                                  author: book.authors?.first ?? "",
                                  image: cell?.image(),
                                  lastUpdated: Date(),
                                  type: .ebook)
            
            model.id = FirestoreManager.DBManager.addBook(book: model, completion: ({ bookId in
                FirebaseStorageManager.DBManager.uploadCover(cover: model.image, bookId: bookId, completion: ({ [weak self] in
                    self?.onAdd?(model)
                }), onError: nil)
            }))
            
            self?.added[indexPath.row] = true
            
        })))
        alert.addAction(UIAlertAction(title: "Нет", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
