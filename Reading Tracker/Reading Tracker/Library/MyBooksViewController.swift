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

public enum BookType: String {
    case paper = "paper"
    case smartphone = "smartphone"
    case tab = "tab"
    case ebook = "ebook"
    case unknown = "unknown"
    
    public static func generate(raw: String) -> BookType {
        switch raw {
        case "paper":
            return .paper
        case "smartphone":
            return .smartphone
        case "tab":
            return .tab
        case "ebook":
            return .ebook
        default:
            return .unknown
        }
    }
}

public struct BookModel {
    public var id: String
    public var title: String
    public var author: String
    public var image: UIImage
    public var lastUpdated: Date
    public var type: BookType
    
    init(id: String = "",
         title: String = "",
         author: String = "",
         image: UIImage? = nil,
         lastUpdated: Date = Date.distantPast,
         type: BookType = .unknown) {
        self.id = id
        self.title = title
        self.author = author
        self.image = image ?? UIImage(named: "bookPlaceholder")!
        self.lastUpdated = lastUpdated
        self.type = type
    }
}

final class MyBooksViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var onBooksListUpdated: (([BookModel]) -> Void)?
    private var spinner: UIActivityIndicatorView?
    private var navBar: NavigationBar?
    private var emptyNavBar: UIView?
    private var books: [BookModel] = []
    private var tableViewTopConstraint: NSLayoutConstraint?
    private var addButton: UIButton?
    private var line: CAShapeLayer?
    private var tableView: UITableView?
    private var handler: AuthStateDidChangeListenerHandle?
    
    convenience init() {
        self.init(nibName: nil, bundle: nil)
        handler = Auth.auth().addStateDidChangeListener { [weak self] (auth, user) in
            if user != nil {
                FirestoreManager.DBManager.getAllBooks(completion: { [weak self] result in
                    self?.books = result
                    self?.update()
                })
            } else {
                self?.books = []
                self?.update()
            }
        }
    }
    
    deinit {
        if let handler = handler {
            Auth.auth().removeStateDidChangeListener(handler)
        }
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?)   {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var bottomSpace: CGFloat = 0
        if #available(iOS 11.0, *) {
            bottomSpace = UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
        }
        navigationController?.navigationBar.isHidden = true
        view.backgroundColor = .white
        setupNavigationBar()
        setupSpinner()
        
        let tableView = UITableView(forAutoLayout: ())
        view.addSubview(tableView)
        tableViewTopConstraint = tableView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: UIApplication.shared.statusBarFrame.height + 4 + 32 + 4, left: 0, bottom: 0, right: 0))[0]
        tableView.register(BookCell.self, forCellReuseIdentifier: "bookCell")
        tableView.tableFooterView = UIView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .white
        tableView.separatorInset = .zero
        tableView.separatorColor = UIColor(rgb: 0x2f5870)
        self.tableView = tableView
        
        let addButton = UIButton(forAutoLayout: ())
        
        addButton.backgroundColor = UIColor(rgb: 0x2f5870)
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
        addButton.autoPinEdge(toSuperviewEdge: .bottom, withInset: 16 + 49 + bottomSpace)
        self.addButton = addButton
        
        let line = CAShapeLayer()
        let linePath = UIBezierPath()
        let width = UIScreen.main.bounds.width
        let height = UIScreen.main.bounds.height
        let start = CGPoint(x: width / 6, y: ((width == 320) ? 190 : 155))
        let end = CGPoint(x: width - 16 - 30, y: height - 16 - 49 - 60 - 8 - bottomSpace)
        linePath.move(to: end)
        linePath.addLine(to: end)
        let dy = end.y - start.y
        linePath.addCurve(to: start,
                          controlPoint1: CGPoint(x: start.x + width, y: start.y + dy / 5),
                          controlPoint2: CGPoint(x: end.x - width, y: end.y - dy / 5))
        
        line.path = linePath.cgPath
        line.strokeColor = UIColor(rgb: 0x2f5870).withAlphaComponent(0.5).cgColor
        line.fillColor = UIColor.white.cgColor
        line.lineWidth = 3.0
        view.layer.addSublayer(line)
        
        self.line = line
        update()
    }
    
    public func pushBook(book: BookModel) {
        books.insert(book, at: 0)
        update()
    }
    
    public func update() {
        update(booksList: books)
    }
    
    public func update(booksList: [BookModel]) {
        if booksList.isEmpty {
            emptyNavBar?.isHidden = false
            tableView?.isHidden = true
            line?.isHidden = false
            tableViewTopConstraint?.constant = emptyNavBar?.frame.height ?? 97
        } else {
            emptyNavBar?.isHidden = true
            tableView?.isHidden = false
            line?.isHidden = true
            tableViewTopConstraint?.constant = 60
        }
        books = booksList
        onBooksListUpdated?(booksList)
        tableView?.reloadData()
    }
    
    @objc private func addBook() {
        let vc = AddBookViewController()
        vc.onCompleted = { [weak self] book in
            self?.pushBook(book: book)
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let moreRowAction = UITableViewRowAction(style: UITableViewRowAction.Style.default, title: "Изменить", handler: { action, indexpath in
            print("Изменить")
        })
        
        moreRowAction.backgroundColor = UIColor(red: 0.298, green: 0.851, blue: 0.3922, alpha: 1.0)
        
        let deleteRowAction = UITableViewRowAction(style: UITableViewRowAction.Style.default, title: "Удалить", handler: { [weak self] action, indexpath in
            guard let strongSelf = self else {
                return
            }
            
            FirestoreManager.DBManager.removeBook(book: strongSelf.books[indexPath.row], onSuccess: ({
                strongSelf.books.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .automatic)
                if indexPath.row == 0 {
                    strongSelf.onBooksListUpdated?(strongSelf.books)
                }
                
                if strongSelf.books.isEmpty {
                    strongSelf.update()
                }
            }), onError: ({
                // show error?
            }))
        })
        
        return [deleteRowAction, moreRowAction]
    }
    
    private func setupNavigationBar() {
        let navBar = NavigationBar()
        navBar.configure(model: NavigationBarModel(title: "Книги"))
        navBar.backgroundColor = UIColor(rgb: 0x2f5870)
        view.addSubview(navBar)
        navBar.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .bottom)
        self.navBar = navBar
        
        let titleTextAttributes = [
            NSAttributedString.Key.foregroundColor : UIColor(rgb: 0x2f5870),
            NSAttributedString.Key.font : UIFont(name: "Avenir-Light", size: 24.0)!]
            as [NSAttributedString.Key : Any]
        let emptyLabel = UILabel(forAutoLayout: ())
        emptyLabel.numberOfLines = 0
        emptyLabel.textAlignment = .center
        emptyLabel.attributedText = NSAttributedString(string: "Для начала, добавьте книги, которые сейчас читаете", attributes: titleTextAttributes)
        view.addSubview(emptyLabel)
        emptyLabel.autoPinEdge(toSuperviewEdge: .left, withInset: 16)
        emptyLabel.autoPinEdge(toSuperviewEdge: .right, withInset: 16)
        emptyLabel.autoPinEdge(.top, to: .bottom, of: navBar, withOffset: 20)
        self.emptyNavBar = emptyLabel
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
    
    override func viewWillDisappear(_ animated: Bool) {
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return books.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "bookCell") as! BookCell
        cell.configure(model: books[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
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
        if let imageView = coverImageView {
            FirebaseStorageManager.DBManager.downloadCover(into: imageView, bookId: model.id, onImageReceived: ({ img in
                self.model.image = img
            }))
        }
    }
}
