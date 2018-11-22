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
import ActionSheetPicker_3_0

struct ChooseCellModel {
    var title: String
    var options: [String]
    
    init(title: String = "",
         options: [String] = [""]) {
        self.title = title
        self.options = options
    }
}

enum QuestionItem {
    case longtext(String)
    case text(String)
    case choose(ChooseCellModel)
}

final class QuestionarreViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    private var spinner: UIActivityIndicatorView?
    private var navBar: NavigationBar!
    private var items: [[QuestionItem]] = [[.text("Имя"),
                                            .text("Фамилия"),
                                            .choose(ChooseCellModel(title: "Пол", options: ["Мужской", "Женский"])),
                                            .choose(ChooseCellModel(title: "Образование", options: ["Среднее общее", "Бакалавр", "Магистр", "Кандидат наук", "Доктор наук", "Другое"])),
                                             .text("Направление образования"),
                                             .text("Сфера деятельности")],
                                           [.longtext("Любимые книги"),
                                            .longtext("Любимые авторы"),
                                            .choose(ChooseCellModel(title: "Формат чтения", options: ["Бумажная книга", "Смартфон", "Планшет", "Электронная книга"]))]]
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
        tableView.register(LongTextFieldCell.self, forCellReuseIdentifier: "longTextFieldCell")
        tableView.register(ChooseCell.self, forCellReuseIdentifier: "chooseCell")
        tableView.tableFooterView = UIView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .white
        tableView.separatorInset = .zero
        tableView.separatorColor = UIColor(rgb: 0x2f5870).withAlphaComponent(0.5)
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.rowHeight = UITableView.automaticDimension
        self.tableView = tableView
    }
    
    public func update(items: [[QuestionItem]]) {
        self.items = items
        tableView?.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
    }
    
    override func viewWillDisappear(_ animated: Bool) {
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items[section].count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: "sectionCell") as! SectionCell
        cell.configure(model: (section == 0) ? "О себе" : "О предпочтениях")
        return cell.contentView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch items[indexPath.section][indexPath.row] {
        case .choose(let model):
            let cell = tableView.dequeueReusableCell(withIdentifier: "chooseCell") as! ChooseCell
            cell.configure(model: model)
            return cell
        case .text(let placeholderText):
            let cell = tableView.dequeueReusableCell(withIdentifier: "textFieldCell") as! TextFieldCell
            cell.configure(model: placeholderText)
            return cell
        case .longtext(let placeholderText):
            let cell = tableView.dequeueReusableCell(withIdentifier: "longTextFieldCell") as! LongTextFieldCell
            cell.configure(model: placeholderText, parent: tableView)
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
        private var model: String = "f"
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
            contentView.addSubview(titleLabel)
            contentView.backgroundColor = .white
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
    
    private class LongTextFieldCell: UITableViewCell, UITextViewDelegate {
        var resultText: String {
            get {
                return field.text ?? ""
            }
            set {
                field.text = newValue
            }
        }
        
        private var parent: UITableView?
        private var model: String = ""
        private var field: UITextView!
        private var placeholder: UILabel?
        
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
            let field = UITextView(frame: .zero)
            field.delegate = self
            field.isScrollEnabled = false
            addSubview(field)
            field.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 32, left: 8, bottom: 8, right: 8))
            field.font = UIFont.systemFont(ofSize: 20)
            self.field = field
            
            let placeholder = UILabel(frame: .zero)
            let textAttributes = [
                NSAttributedString.Key.foregroundColor : UIColor(rgb: 0x2f5870).withAlphaComponent(0.5),
                NSAttributedString.Key.font : UIFont(name: "Avenir-Light", size: 20.0)!]
                as [NSAttributedString.Key : Any]
            
            placeholder.attributedText = NSAttributedString(string: model, attributes: textAttributes)
            
            addSubview(placeholder)
            placeholder.autoPinEdge(toSuperviewEdge: .left, withInset: 16)
            placeholder.autoPinEdge(toSuperviewEdge: .top, withInset: 32 + 4)
            self.placeholder = placeholder
        }
        
        func textViewDidChange(_ textView: UITextView) {
            let size = textView.bounds.size
            let newSize = textView.sizeThatFits(CGSize(width: size.width, height: CGFloat.greatestFiniteMagnitude))
            
            if size.height != newSize.height {
                UIView.setAnimationsEnabled(false)
                parent?.beginUpdates()
                parent?.endUpdates()
                UIView.setAnimationsEnabled(true)
                
                //if let thisIndexPath = parent?.indexPath(for: self) {
                //    parent?.scrollToRow(at: thisIndexPath, at: .bottom, animated: false)
                //}
            }
        }
        
        func textViewDidBeginEditing(_ textView: UITextView) {
            placeholder?.isHidden = true
        }
        
        func textViewDidEndEditing(_ textView: UITextView) {
            placeholder?.isHidden = (textView.text.count > 0)
        }
        
        func configure(model: String, parent: UITableView?) {
            self.model = model
            self.parent = parent
            let textAttributes = [
                NSAttributedString.Key.foregroundColor : UIColor(rgb: 0x2f5870).withAlphaComponent(0.5),
                NSAttributedString.Key.font : UIFont(name: "Avenir-Light", size: 20.0)!]
                as [NSAttributedString.Key : Any]
            
            placeholder?.attributedText = NSAttributedString(string: model, attributes: textAttributes)
        }
    }
    
    private class ChooseCell: UITableViewCell {
        private var model = ChooseCellModel()
        private var mainButton: UIButton!
        
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
            let mainTextAttributes = [
                NSAttributedString.Key.foregroundColor : UIColor(rgb: 0x2f5870).withAlphaComponent(0.5),
                NSAttributedString.Key.font : UIFont(name: "Avenir-Light", size: 20.0)!]
                as [NSAttributedString.Key : Any]
            
            let mainButton = UIButton(forAutoLayout: ())
            mainButton.setAttributedTitle(NSAttributedString(string: model.title, attributes: mainTextAttributes), for: [])
            mainButton.contentHorizontalAlignment = .left
            addSubview(mainButton)
            mainButton.autoSetDimension(.height, toSize: 32)
            mainButton.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 32, left: 16, bottom: 8, right: 16))
            
            mainButton.addTarget(self, action: #selector(mainButtonTap), for: .touchUpInside)
            
            let arrowImageView = UIImageView(image: UIImage(named: "down"))
            mainButton.addSubview(arrowImageView)
            arrowImageView.autoSetDimensions(to: CGSize(width: 10, height: 5))
            arrowImageView.autoAlignAxis(toSuperviewAxis: .horizontal)
            arrowImageView.autoPinEdge(toSuperviewEdge: .right)
            
            self.mainButton = mainButton
        }
        
        func configure(model: ChooseCellModel) {
            self.model = model
            
            let textAttributes = [
                NSAttributedString.Key.foregroundColor : UIColor(rgb: 0x2f5870).withAlphaComponent(0.5),
                NSAttributedString.Key.font : UIFont(name: "Avenir-Light", size: 20.0)!]
                as [NSAttributedString.Key : Any]
            
            mainButton.setAttributedTitle(NSAttributedString(string: model.title, attributes: textAttributes), for: [])
        }
        
        @objc private func mainButtonTap(_ sender: UIButton) {
            let picker = ActionSheetMultipleStringPicker(title: model.title, rows: [model.options],
                                                         initialSelection: [0], doneBlock: { [weak self]
                    picker, values, indexes in
                    let textAttributes = [
                        NSAttributedString.Key.foregroundColor : UIColor(rgb: 0x2f5870),
                        NSAttributedString.Key.font : UIFont(name: "Avenir-Medium", size: 20.0)!]
                        as [NSAttributedString.Key : Any]
                    if let values = values,
                        let optionIndex = values.first as? Int,
                        let text = self?.model.options[optionIndex] {
                        sender.setAttributedTitle(NSAttributedString(string: text, attributes: textAttributes), for: [])
                    }
                                                            
                    return
                }, cancel: { ActionMultipleStringCancelBlock in return }, origin: sender)
            picker?.setTextColor(UIColor(rgb: 0x2f5870))
            
            let textAttributes = [
                NSAttributedString.Key.foregroundColor : UIColor(rgb: 0x2f5870),
                NSAttributedString.Key.font : UIFont(name: "Avenir-Medium", size: 17.0)!]
                as [NSAttributedString.Key : Any]
            
            let finishButton = UIButton(forAutoLayout: ())
            finishButton.setAttributedTitle(NSAttributedString(string: "Готово", attributes: textAttributes), for: [])
            picker?.setDoneButton(UIBarButtonItem(customView: finishButton))
            
            let closeButton = UIButton(forAutoLayout: ())
            closeButton.setAttributedTitle(NSAttributedString(string: "Закрыть", attributes: textAttributes), for: [])
            picker?.setCancelButton(UIBarButtonItem(customView: closeButton))
            picker?.show()
        }
    }
}
