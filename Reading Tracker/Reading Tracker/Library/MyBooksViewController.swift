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
import BarcodeScanner

final class MyBooksViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,
BarcodeScannerCodeDelegate, BarcodeScannerErrorDelegate, BarcodeScannerDismissalDelegate {
    var onBooksListUpdated: (([BookModel]) -> Void)?
    var onTapToStartSession: ((BookModel) -> Void)?
    private var spinner: SpinnerView?
    private var navBar: NavigationBar?
    private var emptyNavBar: UIView?
    private var books: [BookModel] = []
    private var tableViewTopConstraint: NSLayoutConstraint?
    private var addButton: UIButton?
    private var line: CAShapeLayer?
    private var tableView: UITableView?
    private var handler: AuthStateDidChangeListenerHandle?
    private var isLoaded = false
    
    convenience init() {
        self.init(nibName: nil, bundle: nil)
        handler = Auth.auth().addStateDidChangeListener { [weak self] (auth, user) in
            if user != nil {
                FirestoreManager.DBManager.getAllBooks(completion: { [weak self] result in
                    self?.isLoaded = true
                    self?.spinner?.hide()
                    self?.books = result
                    self?.update()
                    }, onError: ({ [weak self] in
                        self?.isLoaded = true
                        self?.spinner?.hide()
                    }))
            } else {
                self?.isLoaded = false
                self?.spinner?.hide()
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
        var bottomSpace: CGFloat = 49
        if #available(iOS 11.0, *) {
            bottomSpace += UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
        }
        navigationController?.navigationBar.isHidden = true
        view.backgroundColor = .white
        setupNavigationBar()
        
        let tableView = UITableView(forAutoLayout: ())
        view.addSubview(tableView)
        tableViewTopConstraint = tableView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: UIApplication.shared.statusBarFrame.height + 4 + 32 + 4, left: 0, bottom: bottomSpace, right: 0))[0]
        tableView.register(BookCell.self, forCellReuseIdentifier: "bookCell")
        tableView.tableFooterView = UIView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .white
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.separatorColor = UIColor(rgb: 0x2f5870)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 190
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
        addButton.autoPinEdge(toSuperviewEdge: .bottom, withInset: 16 + bottomSpace)
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
        
        setupSpinner()
        if isLoaded {
            spinner?.hide()
        } else {
            spinner?.show()
        }
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
        if booksList.filter({ !$0.isDeleted }).isEmpty {
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
        let title = "Добавить фото обложки книги?"
        let msg = "Добавить можно лишь информацию о книге, которую вы читаете: название, автор, обложка."
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Найти по штрих-коду", style: .default, handler: ({ [weak self] _ in
            let vc = BarcodeScannerViewController()
            vc.codeDelegate = self
            vc.errorDelegate = self
            vc.dismissalDelegate = self
            
            self?.present(vc, animated: true, completion: nil)
        })))
        
        alert.addAction(UIAlertAction(title: "Найти по названию", style: .default, handler: ({ [weak self] _ in
            let vc = BookTextSearchViewController()
            vc.onAdd = { [weak self] book in
                self?.pushBook(book: book)
            }
            self?.navigationController?.pushViewController(vc, animated: true)
        })))
        alert.addAction(UIAlertAction(title: "Ввести вручную", style: .default, handler: ({ [weak self] _ in
            let vc = AddBookViewController()
            vc.onCompleted = { [weak self] book in
                self?.pushBook(book: book)
            }
            self?.navigationController?.pushViewController(vc, animated: true)
        })))
        
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func scanner(_ controller: BarcodeScannerViewController, didCaptureCode code: String, type: String) {
        controller.dismiss(animated: true, completion: nil)
        spinner?.show()
        let queryText = "isbn:" + code
        
        let query = BookQuery(searchText: queryText,
                              startIndex: 0,
                              maxResults: 40,
                              filter: .paidEbooks,
                              orderBy: .relevance)
        
        APIManager.instance.book.get(bookQuery: query) { [weak self] result in
            self?.spinner?.hide()
            
            switch result {
            case .success(let booksList):
                guard !booksList.isEmpty else {
                    self?.alertError(reason: "По вашему запросу ничего не найдено")
                    return
                }
                
                let vc = BookTextSearchResultViewController()
                vc.onAdd = { [weak self] book in
                    self?.pushBook(book: book)
                }
                vc.update(books: booksList)
                self?.navigationController?.pushViewController(vc, animated: true)
            case .failure(let error):
                self?.alertError(reason: error.localizedDescription)
            }
        }
    }
    
    private func alertError(reason: String) {
        let alert = UIAlertController(title: "Ошибка!", message: reason, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ок", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func scanner(_ controller: BarcodeScannerViewController, didReceiveError error: Error) {
        print(error)
    }
    
    func scannerDidDismiss(_ controller: BarcodeScannerViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let moreRowAction = UITableViewRowAction(style: UITableViewRowAction.Style.default, title: "Изменить", handler: { [weak self] action, indexpath in
            guard let strongSelf = self else {
                return
            }
            
            let vc = EditBookViewController(model: strongSelf.books.filter({ !$0.isDeleted })[indexpath.row])
            
            vc.onCompleted = { [weak self] updatedBook in
                let oldBook = strongSelf.books.filter({ !$0.isDeleted })[indexpath.row]
                for i in 0..<strongSelf.books.count {
                    if strongSelf.books[i].id == oldBook.id {
                        strongSelf.books[i] = updatedBook
                        break
                    }
                }
                self?.update()
            }
            
            strongSelf.navigationController?.pushViewController(vc, animated: true)
        })
        
        moreRowAction.backgroundColor = UIColor(red: 0.298, green: 0.851, blue: 0.3922, alpha: 1.0)
        
        let deleteRowAction = UITableViewRowAction(style: UITableViewRowAction.Style.default, title: "Удалить", handler: { [weak self] action, indexpath in
            guard let strongSelf = self else {
                return
            }
            
            FirestoreManager.DBManager.removeBook(book: strongSelf.books.filter({ !$0.isDeleted })[indexPath.row], onSuccess: ({
                let oldBook = strongSelf.books.filter({ !$0.isDeleted })[indexpath.row]
                for i in 0..<strongSelf.books.count {
                    if strongSelf.books[i].id == oldBook.id {
                        strongSelf.books[i].isDeleted = true
                        break
                    }
                }
                tableView.deleteRows(at: [indexPath], with: .automatic)
                if indexPath.row == 0 {
                    strongSelf.onBooksListUpdated?(strongSelf.books)
                }
                
                if strongSelf.books.filter({ !$0.isDeleted }).isEmpty {
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
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: 24, weight: .regular)]
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
        let spinner = SpinnerView(frame: .zero)
        view.addSubview(spinner)
        
        view.bringSubviewToFront(spinner)
        spinner.autoPinEdgesToSuperviewEdges()
        self.spinner = spinner
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return books.filter({ !$0.isDeleted }).count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "bookCell") as! BookCell
        cell.configure(model: books.filter({ !$0.isDeleted })[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let book = books.filter({ !$0.isDeleted })[indexPath.row]
        onTapToStartSession?(book)
    }
}
