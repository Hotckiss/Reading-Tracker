//
//  QuestionarreViewController.swift
//  Reading Tracker
//
//  Created by Andrei Kirilenko on 19/11/2018.
//  Copyright © 2018 Andrei Kirilenko. All rights reserved.
//

import Foundation
import UIKit
import Firebase

enum QuestionItem {
    case text(String)
    case choose(Int)
}

final class QuestionarreViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    private var spinner: UIActivityIndicatorView?
    private var navBar: NavigationBar!
    private var itemsSelf: [QuestionItem] = [.text("Имя"), .text("Фамилия"), .choose(0), .choose(0),
                                             .text("Направление образования"), .text("Сфера деятельности")]
    private var itemsReading: [QuestionItem] = [.text("Любимые книги"), .text("Любимые авторы"), .choose(0)]
    private var tableView: UITableView?
    private var handler: AuthStateDidChangeListenerHandle?
    
    convenience init() {
        self.init(nibName: nil, bundle: nil)
        handler = Auth.auth().addStateDidChangeListener { [weak self] (auth, user) in
            if user != nil {
                //load info
                
                //FirestoreManager.DBManager.getAllBooks(completion: { [weak self] result in
                //    self?.books = result
                //    self?.update()
                //})
            } else {
                //clear info
                
                //self?.books = []
                //self?.update()
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
        navigationController?.navigationBar.isHidden = true
        view.backgroundColor = .white
        setupNavigationBar()
        setupSpinner()
        
        let tableView = UITableView(forAutoLayout: ())
        view.addSubview(tableView)
        tableView.autoPinEdge(.top, to: .bottom, of: navBar)
        tableView.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .top)
        tableView.register(SectionCell.self, forCellReuseIdentifier: "sectionCell")
        tableView.register(TextFieldCell.self, forCellReuseIdentifier: "textFieldCell")
        tableView.tableFooterView = UIView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .white
        tableView.separatorInset = .zero
        tableView.separatorColor = UIColor(rgb: 0x2f5870).withAlphaComponent(0.5)
        //tableView.separatorInset = UIEdgeInsets(top: 1, left: 16, bottom: 1, right: 16)
        self.tableView = tableView
    }
    
    public func update(itemsSelf: [QuestionItem], itemsReading: [QuestionItem]) {
        self.itemsSelf = itemsSelf
        self.itemsReading = itemsReading
        tableView?.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
    }
    
    override func viewWillDisappear(_ animated: Bool) {
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (section == 0) ? itemsSelf.count : itemsReading.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: "sectionCell") as! SectionCell
        cell.configure(model: (section == 0) ? "О себе" : "О предпочтениях")
        return cell
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "textFieldCell") as! TextFieldCell
            var placeholder = ""
            switch itemsSelf[indexPath.row] {
            case .choose(let index):
                placeholder = "TODO"
            case .text(let placeholderText):
                placeholder = placeholderText
            }
            cell.configure(model: placeholder)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "textFieldCell") as! TextFieldCell
            var placeholder = ""
            switch itemsSelf[indexPath.row] {
            case .choose(let index):
                placeholder = "TODO"
            case .text(let placeholderText):
                placeholder = placeholderText
            }
            cell.configure(model: placeholder)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
    
    private func setupNavigationBar() {
        let navBar = NavigationBar()
        navBar.configure(model: NavigationBarModel(title: "Анкета участника",
                                                   backButtonText: "Назад",
                                                   frontButtonText: "Сохранить",
                                                   onBackButtonPressed: ({ [weak self] in
                                                    self?.navigationController?.popViewController(animated: true)
                                                   }),
                                                   onFrontButtonPressed: ({
                                                    //todo -- upload
                                                   })))
        navBar.backgroundColor = UIColor(rgb: 0x2f5870)
        view.addSubview(navBar)
        navBar.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .bottom)
        self.navBar = navBar
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
    
    private class SectionCell: UITableViewCell {
        private var model: String = ""
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
            
            let titleTextAttributes = [
                NSAttributedString.Key.foregroundColor : UIColor(rgb: 0x2f5870),
                NSAttributedString.Key.font : UIFont(name: "Avenir-Medium", size: 20.0)!]
                as [NSAttributedString.Key : Any]
            
            titleLabel.attributedText = NSAttributedString(string: model, attributes: titleTextAttributes)
            titleLabel.numberOfLines = 0
            addSubview(titleLabel)
            titleLabel.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 16, left: 16, bottom: 0, right: 16))
            self.titleLabel = titleLabel
        }
        
        func configure(model: String) {
            self.model = model
            
            let titleTextAttributes = [
                NSAttributedString.Key.foregroundColor : UIColor(rgb: 0x2f5870),
                NSAttributedString.Key.font : UIFont(name: "Avenir-Medium", size: 20.0)!]
                as [NSAttributedString.Key : Any]
            
            titleLabel?.attributedText = NSAttributedString(string: model, attributes: titleTextAttributes)
        }
    }
    
    private class TextFieldCell: UITableViewCell {
        var resultText: String {
            get {
                return field.text ?? ""
            }
            set {
                field.text = newValue
            }
        }

        private var model: String = ""
        private var field: RTTextField!
        
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
            let field = RTTextField(frame: .zero)
            
            let textAttributes = [
                NSAttributedString.Key.foregroundColor : UIColor(rgb: 0x2f5870).withAlphaComponent(0.5),
                NSAttributedString.Key.font : UIFont(name: "Avenir-Light", size: 20.0)!]
                as [NSAttributedString.Key : Any]
            
            field.attributedPlaceholder = NSAttributedString(string: model, attributes: textAttributes)
            addSubview(field)
            field.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 32, left: 8, bottom: 8, right: 8))
            self.field = field
        }
        
        func configure(model: String) {
            self.model = model
            
            let textAttributes = [
                NSAttributedString.Key.foregroundColor : UIColor(rgb: 0x2f5870).withAlphaComponent(0.5),
                NSAttributedString.Key.font : UIFont(name: "Avenir-Light", size: 20.0)!]
                as [NSAttributedString.Key : Any]
            
            field.attributedPlaceholder = NSAttributedString(string: model, attributes: textAttributes)
        }
    }
}
