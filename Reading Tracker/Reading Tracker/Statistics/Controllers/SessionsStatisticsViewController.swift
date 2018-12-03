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
    private var books: [BookModel] = [BookModel(id: "1", title: "1111", author: "2e", image: nil, lastUpdated: Date(), type: .paper),
                                      BookModel(id: "1", title: "2222", author: "2e", image: nil, lastUpdated: Date(), type: .paper),
                                      BookModel(id: "1", title: "3333", author: "2e", image: nil, lastUpdated: Date(), type: .paper),
                                      BookModel(id: "1", title: "4444", author: "2e", image: nil, lastUpdated: Date(), type: .paper),
                                      BookModel(id: "1", title: "5555", author: "2e", image: nil, lastUpdated: Date(), type: .paper),
                                      BookModel(id: "1", title: "6666", author: "2e", image: nil, lastUpdated: Date(), type: .paper)]
    private var tableView: UITableView?
    
    init() {
        super.init(nibName: nil, bundle: nil)
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
        tableView.register(BookCell.self, forCellReuseIdentifier: "sessionCell")
        tableView.tableFooterView = UIView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .white
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.separatorColor = UIColor(rgb: 0x2f5870)
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
        return books.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "sessionCell") as! BookCell
        cell.configure(model: books[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let book = books[indexPath.row]
        //onTapToStartSession?(book)
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
