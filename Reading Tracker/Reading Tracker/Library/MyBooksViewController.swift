//
//  MyBooksViewController.swift
//  Reading Tracker
//
//  Created by Andrei Kirilenko on 15.10.2018.
//  Copyright © 2018 Andrei Kirilenko. All rights reserved.
//

import Foundation
import UIKit
import Firebase

public struct BookModel {
    public var icbn: String
    public var title: String
    public var author: String
    public var image: UIImage
    public var lastUpdated: Date
    
    init(icbn: String = "226611156", title: String, author: String, image: UIImage? = nil, lastUpdated: Date = Date.distantPast) {
        self.icbn = icbn
        self.title = title
        self.author = author
        self.image = (image ?? UIImage(named: "bookPlaceholder")) ?? UIImage()
        self.lastUpdated = lastUpdated
    }
}

final class MyBooksViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    private var spinner: UIActivityIndicatorView?
    private var navBar: NavigationBar?
    private var emptyNavBar: UIView?
    private var books: [BookModel] = []
    private var tableViewTopConstraint: NSLayoutConstraint?
    private var addButton: UIButton?
    private var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        view.backgroundColor = .white
        setupNavigationBar()
        setupSpinner()
        
        tableView = UITableView(forAutoLayout: ())
        view.addSubview(tableView)
        tableViewTopConstraint = tableView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: UIApplication.shared.statusBarFrame.height + 4 + 32 + 4, left: 0, bottom: 0, right: 0))[0]
        tableView.register(BookCell.self, forCellReuseIdentifier: "bookCell")
        tableView.tableFooterView = UIView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .white
        tableView.separatorInset = .zero
        tableView.separatorColor = UIColor(rgb: 0x2f5870)
        
        let addButton = UIButton(forAutoLayout: ())
        
        addButton.backgroundColor = UIColor(rgb: 0xedaf97)
        let icon = UIImage(named: "plus")
        addButton.imageEdgeInsets = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        addButton.setImage(icon, for: [])
        addButton.addTarget(self, action: #selector(addBook), for: .touchUpInside)
        addButton.layer.cornerRadius = 30
        addButton.layer.shadowColor = UIColor.black.cgColor
        addButton.layer.shadowOpacity = 0.2
        addButton.layer.shadowOffset = CGSize(width: 0.0, height: 3.0)
        view.addSubview(addButton)
        view.bringSubviewToFront(addButton)
        addButton.autoSetDimensions(to: CGSize(width: 60, height: 60))
        addButton.autoPinEdge(toSuperviewEdge: .right, withInset: 16)
        addButton.autoPinEdge(toSuperviewEdge: .bottom, withInset: 16 + 49)
        self.addButton = addButton
        
        //todo: удалить мусор
        update(booksList: [BookModel(icbn: "1", title: "Биоцентризм. Как жизнь создает вселенную", author: "Роберт Ланца"),
                           BookModel(icbn: "2", title: "Фату-Хива: возврат к природе", author: "Тур Хейердал")])
    }
    
    public func update(booksList: [BookModel]) {
        if booksList.isEmpty {
            navBar?.isHidden = true
            emptyNavBar?.isHidden = false
            tableView.isHidden = true
            tableViewTopConstraint?.constant = emptyNavBar?.frame.height ?? 97
        } else {
            navBar?.isHidden = false
            emptyNavBar?.isHidden = true
            tableView.isHidden = false
            tableViewTopConstraint?.constant = 60
        }
        books = booksList
        tableView.reloadData()
    }
    
    @objc private func addBook() {
        let alert = UIAlertController(title: "Ошибка!", message: "TODO: форма добавления", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ок", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        
        // уже работает
        //FirestoreManager.DBManager.addBook(book: BookModel(icbn: "1113", title: "Биоцентризм. Как жизнь создает вселенную", author: "Роберт Ланца"))
    }
    
    private func setupNavigationBar() {
        let navBar = NavigationBar()
        navBar.configure(model: NavigationBarModel(title: "Выберите книгу"))
        navBar.backgroundColor = UIColor(rgb: 0xedaf97)
        view.addSubview(navBar)
        navBar.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .bottom)
        self.navBar = navBar
        
        let emptyNavBar = UIView(forAutoLayout: ())
        let titleTextAttributes = [
            NSAttributedString.Key.foregroundColor : UIColor.white,
            NSAttributedString.Key.font : UIFont(name: "Avenir-Light", size: 24.0)!]
            as [NSAttributedString.Key : Any]
        let emptyLabel = UILabel(forAutoLayout: ())
        emptyLabel.numberOfLines = 0
        emptyLabel.textAlignment = .center
        emptyLabel.attributedText = NSAttributedString(string: "Для начала, добавьте книги, которые сейчас читаете", attributes: titleTextAttributes)
        emptyNavBar.addSubview(emptyLabel)
        emptyNavBar.backgroundColor = UIColor(rgb: 0xedaf97)
        view.addSubview(emptyNavBar)
        emptyNavBar.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .bottom)
        emptyLabel.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 28, left: 16, bottom: 12, right: 16))
        self.emptyNavBar = emptyNavBar
    }
    
    private func setupSpinner() {
        let spinner = UIActivityIndicatorView()
        view.addSubview(spinner)
        
        view.bringSubviewToFront(spinner)
        spinner.autoCenterInSuperview()
        spinner.backgroundColor = UIColor(rgb: 0x555555).withAlphaComponent(0.7)
        spinner.layer.cornerRadius = 8
        spinner.autoSetDimensions(to: CGSize(width: 64, height: 64))
        self.spinner = spinner
    }
    
    override func viewWillAppear(_ animated: Bool) {
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return books.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: BookCell = self.tableView.dequeueReusableCell(withIdentifier: "bookCell") as! BookCell
        cell.configure(model: books[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
    
    private class BookCell: UITableViewCell {
        private var model: BookModel = BookModel(title: "", author: "")
        private var titleLabel: UILabel?
        private var authorLabel: UILabel?
        private var coverImageView: UIImageView?
        
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
            
            let titleTextAttributes = [
                NSAttributedString.Key.foregroundColor : UIColor(rgb: 0x2f5870),
                NSAttributedString.Key.font : UIFont(name: "Avenir-Medium", size: 20.0)!]
                as [NSAttributedString.Key : Any]
            
            titleLabel.attributedText = NSAttributedString(string: model.title, attributes: titleTextAttributes)
            titleLabel.numberOfLines = 0
            
            let authorLabel = UILabel(forAutoLayout: ())
            
            let authorTextAttributes = [
                NSAttributedString.Key.foregroundColor : UIColor(rgb: 0x2f5870),
                NSAttributedString.Key.font : UIFont(name: "Avenir-Medium", size: 14.0)!]
                as [NSAttributedString.Key : Any]
            
            authorLabel.attributedText = NSAttributedString(string: model.author, attributes: authorTextAttributes)
            authorLabel.numberOfLines = 0
            
            let coverImageView = UIImageView(image: model.image)
            coverImageView.contentMode = .scaleAspectFill
            
            addSubview(titleLabel)
            
            titleLabel.autoPinEdge(toSuperviewEdge: .left, withInset: 16)
            titleLabel.autoPinEdge(toSuperviewEdge: .right, withInset: 16 + 70 + 16)
            titleLabel.autoPinEdge(toSuperviewEdge: .top, withInset: 20)
            
            addSubview(authorLabel)
            
            authorLabel.autoPinEdge(toSuperviewEdge: .left, withInset: 16)
            authorLabel.autoPinEdge(toSuperviewEdge: .right, withInset: 16 + 70 + 16)
            authorLabel.autoPinEdge(.top, to: .bottom, of: titleLabel, withOffset: 5)
            
            addSubview(coverImageView)
            
            coverImageView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 16), excludingEdge: .left)
            coverImageView.autoSetDimensions(to: CGSize(width: 70, height: 100))
            
            self.titleLabel = titleLabel
            self.authorLabel = authorLabel
            self.coverImageView = coverImageView
        }
        
        func configure(model: BookModel) {
            self.model = model
            
            let titleTextAttributes = [
                NSAttributedString.Key.foregroundColor : UIColor(rgb: 0x2f5870),
                NSAttributedString.Key.font : UIFont(name: "Avenir-Medium", size: 20.0)!]
                as [NSAttributedString.Key : Any]
            
            let authorTextAttributes = [
                NSAttributedString.Key.foregroundColor : UIColor(rgb: 0x2f5870),
                NSAttributedString.Key.font : UIFont(name: "Avenir-Medium", size: 14.0)!]
                as [NSAttributedString.Key : Any]
            
            titleLabel?.attributedText = NSAttributedString(string: model.title, attributes: titleTextAttributes)
            authorLabel?.attributedText = NSAttributedString(string: model.author, attributes: authorTextAttributes)
            coverImageView?.image = model.image
        }
    }
}
