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
    var selectedIndex: Int?
    var options: [String]
    
    init(title: String = "",
         selectedIndex: Int? = nil,
         options: [String] = [""]) {
        self.title = title
        self.selectedIndex = selectedIndex
        self.options = options
    }
}

struct TextCellModel {
    var placeholder: String
    var text: String
    
    init(placeholder: String = "",
         text: String = "") {
        self.placeholder = placeholder
        self.text = text
    }
}


enum Sex: String {
    case male = "male"
    case female = "female"
    case unknown = "unknown"
    
    init(raw: Int?) {
        if let int = raw {
            self = (int == 0) ? .male : .female
        } else {
            self = .unknown
        }
    }
    
    func index() -> Int? {
        switch self {
        case .male:
            return 0
        case .female:
            return 1
        case .unknown:
            return nil
        }
    }
        
    init(str: String) {
        switch str {
        case "male":
            self = .male
        case "female":
            self = .female
        default:
            self = .unknown
        }
    }
}

enum Education: String {
    case middle = "middle"
    case bachelor = "bachelor"
    case master = "master"
    case candidate = "candidate"
    case doctor = "doctor"
    case other = "other"
    case unknown = "unknown"
    
    func index() -> Int? {
        switch self {
        case .middle:
            return 0
        case .bachelor:
            return 1
        case .master:
            return 2
        case .candidate:
            return 3
        case .doctor:
            return 4
        case .other:
            return 5
        case .unknown:
            return nil
        }
    }
        
    init(raw: Int?) {
        if let int = raw {
            switch int {
            case 0:
                self = .middle
            case 1:
                self = .bachelor
            case 2:
                self = .master
            case 3:
                self = .candidate
            case 4:
                self = .doctor
            default:
                self = .other
            }
        } else {
            self = .unknown
        }
    }
    
    init(str: String) {
        switch str {
        case "middle":
            self = .middle
        case "bachelor":
            self = .bachelor
        case "master":
            self = .master
        case "candidate":
            self = .candidate
        case "doctor":
            self = .doctor
        case "other":
            self = .other
        default:
            self = .unknown
        }
    }
}

struct Questionarrie {
    var firstName: String
    var lastName: String
    var sex: Sex
    var education: Education
    var major: String
    var workSphere: String
    var favoriteAuthors: String
    var favoriteBooks: String
    var bookType: BookType
    
    init(firstName: String,
         lastName: String,
         sex: Sex,
         education: Education,
         major: String,
         workSphere: String,
         favoriteAuthors: String,
         favoriteBooks: String,
         bookType: BookType) {
        self.firstName = firstName
        self.lastName = lastName
        self.sex = sex
        self.education = education
        self.major = major
        self.workSphere = workSphere
        self.favoriteBooks = favoriteBooks
        self.favoriteAuthors = favoriteAuthors
        self.bookType = bookType
    }
    
    init(firstName: String,
         lastName: String,
         sex: Int?,
         education: Int?,
         major: String,
         workSphere: String,
         favoriteAuthors: String,
         favoriteBooks: String,
         bookType: Int?) {
        self.firstName = firstName
        self.lastName = lastName
        self.sex = Sex(raw: sex)
        self.education = Education(raw: education)
        self.major = major
        self.workSphere = workSphere
        self.favoriteBooks = favoriteBooks
        self.favoriteAuthors = favoriteAuthors
        self.bookType = BookType(raw: bookType)
    }
    
    init() {
        self.init(firstName: "",
                  lastName: "",
                  sex: .unknown,
                  education: .unknown,
                  major: "",
                  workSphere: "",
                  favoriteAuthors: "",
                  favoriteBooks: "",
                  bookType: .unknown)
    }
}

enum QuestionItem {
    case longtext(TextCellModel)
    case text(TextCellModel)
    case choose(ChooseCellModel)
}

final class QuestionarreViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var questionarrie = Questionarrie()
    private var spinner: SpinnerView?
    private var navBar: NavigationBar!
    private var items: [[QuestionItem]] = [[.text(TextCellModel(placeholder: "Имя", text: "")),
                                            .text(TextCellModel(placeholder: "Фамилия", text: "")),
                                            .choose(ChooseCellModel(title: "Пол", options: ["Мужской", "Женский"])),
                                            .choose(ChooseCellModel(title: "Образование", options: ["Среднее общее", "Бакалавр", "Магистр", "Кандидат наук", "Доктор наук", "Другое"])),
                                             .text(TextCellModel(placeholder: "Направление образования", text: "")),
                                             .text(TextCellModel(placeholder: "Сфера деятельности", text: ""))],
                                           [.longtext(TextCellModel(placeholder: "Любимые книги", text: "")),
                                            .longtext(TextCellModel(placeholder: "Любимые авторы", text: "")),
                                            .choose(ChooseCellModel(title: "Формат чтения", options: ["Бумажная книга", "Электронная книга", "Смартфон", "Планшет"]))]]
    private var tableView: UITableView?
    private var tableViewBottomConstraint: NSLayoutConstraint?
    private var handler: AuthStateDidChangeListenerHandle?
    
    convenience init() {
        self.init(nibName: nil, bundle: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    deinit {
        if let handler = handler {
            Auth.auth().removeStateDidChangeListener(handler)
        }
        NotificationCenter.default.removeObserver(UIResponder.keyboardWillShowNotification)
        NotificationCenter.default.removeObserver(UIResponder.keyboardWillHideNotification)
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
        
        var bottomSpace: CGFloat = 49
        if #available(iOS 11.0, *) {
            bottomSpace += UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
        }
        
        let tableView = UITableView(forAutoLayout: ())
        view.addSubview(tableView)
        tableView.autoPinEdge(.top, to: .bottom, of: navBar)
        tableViewBottomConstraint = tableView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 0, left: 0, bottom: bottomSpace, right: 0), excludingEdge: .top)[1]
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
        tableView.estimatedRowHeight = 190
        self.tableView = tableView
        
        setupSpinner()
        spinner?.show()
        handler = Auth.auth().addStateDidChangeListener { [weak self] (auth, user) in
            if user != nil {
                FirestoreManager.DBManager.downloadQuestionarrie(onCompleted: ({ [weak self] q in
                    self?.spinner?.hide()
                    self?.questionarrie = q
                    self?.items = [[.text(TextCellModel(placeholder: "Имя", text: q.firstName)),
                                    .text(TextCellModel(placeholder: "Фамилия", text: q.lastName)),
                                    .choose(ChooseCellModel(title: "Пол", selectedIndex: q.sex.index(),  options: ["Мужской", "Женский"])),
                                    .choose(ChooseCellModel(title: "Образование", selectedIndex: q.education.index(), options: ["Среднее общее", "Бакалавр", "Магистр", "Кандидат наук", "Доктор наук", "Другое"])),
                                    .text(TextCellModel(placeholder: "Направление образования", text: q.major)),
                                    .text(TextCellModel(placeholder: "Сфера деятельности", text: q.workSphere))],
                                   [.longtext(TextCellModel(placeholder: "Любимые книги", text: q.favoriteBooks)),
                                    .longtext(TextCellModel(placeholder: "Любимые авторы", text: q.favoriteAuthors)),
                                    .choose(ChooseCellModel(title: "Формат чтения", selectedIndex: q.bookType.index(), options: ["Бумажная книга", "Электронная книга", "Смартфон", "Планшет"]))]]
                    self?.tableView?.reloadData()
                }), onError: ({ [weak self] in
                    self?.spinner?.hide()
                    let alert = UIAlertController(title: "Ошибка!", message: "Не удалось скачать анкету", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ок", style: .default, handler: nil))
                    self?.present(alert, animated: true, completion: nil)
                }))
            } else {
                self?.questionarrie = Questionarrie()
            }
        }
    }
    
    public func update(items: [[QuestionItem]]) {
        self.items = items
        tableView?.reloadData()
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            tableViewBottomConstraint?.constant = -(keyboardSize.height)
        }
        
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        tableViewBottomConstraint?.constant = 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items[section].count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 42.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 42))
        let titleLabel = UILabel(forAutoLayout: ())
        let titleTextAttributes = [
            NSAttributedString.Key.foregroundColor : UIColor(rgb: 0x2f5870),
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: 20, weight: .regular)]
            as [NSAttributedString.Key : Any]
        
        titleLabel.attributedText = NSAttributedString(string: (section == 0) ? "О себе" : "О предпочтениях", attributes: titleTextAttributes)
        titleLabel.numberOfLines = 0
        headerView.addSubview(titleLabel)
        headerView.backgroundColor = .white
        titleLabel.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 16, left: 16, bottom: 0, right: 16))
        return headerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch items[indexPath.section][indexPath.row] {
        case .choose(let model):
            let cell = tableView.dequeueReusableCell(withIdentifier: "chooseCell") as! ChooseCell
            cell.configure(model: model, onUpdate: ({ [weak self] indq in
                if indexPath.section == 0 && indexPath.row == 2 {
                    self?.questionarrie.sex = Sex(raw: indq)
                } else if indexPath.section == 0 && indexPath.row == 3 {
                    self?.questionarrie.education = Education(raw: indq)
                } else {
                    self?.questionarrie.bookType = BookType(raw: indq)
                }
            }))
            return cell
        case .text(let model):
            let cell = tableView.dequeueReusableCell(withIdentifier: "textFieldCell") as! TextFieldCell
            cell.configure(model: model, onUpdate: ({ [weak self] str in
                if indexPath.row == 0 {
                    self?.questionarrie.firstName = str
                } else if indexPath.row == 1 {
                    self?.questionarrie.lastName = str
                } else if indexPath.row == 4 {
                    self?.questionarrie.major = str
                } else {
                    self?.questionarrie.workSphere = str
                }
            }))
            return cell
        case .longtext(let model):
            let cell = tableView.dequeueReusableCell(withIdentifier: "longTextFieldCell") as! LongTextFieldCell
            cell.configure(model: model, parent: tableView, onUpdate: ({ [weak self] str in
                if indexPath.row == 0 {
                    self?.questionarrie.favoriteBooks = str
                } else {
                    self?.questionarrie.favoriteAuthors = str
                }
            }))
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
    
    private func setupNavigationBar() {
        let navBar = NavigationBar()
        navBar.configure(model: NavigationBarModel(title: "Анкета участника",
                                                   onBackButtonPressed: ({ [weak self] in
                                                    self?.navigationController?.popViewController(animated: true)
                                                   }),
                                                   onFrontButtonPressed: ({ [weak self] in
                                                    self?.spinner?.show()
                                                    guard let strongSelf = self else {
                                                        self?.spinner?.hide()
                                                        let alert = UIAlertController(title: "Ошибка!", message: "Неизвестная ошибка", preferredStyle: .alert)
                                                        alert.addAction(UIAlertAction(title: "Ок", style: .default, handler: nil))
                                                        self?.present(alert, animated: true, completion: nil)
                                                        return
                                                    }
                                                    FirestoreManager.DBManager.updateQuestionarre(q: strongSelf.questionarrie,
                                                                                                  onError: ({ err in
                                                                                                    self?.spinner?.hide()
                                                                                                    strongSelf.alertError(reason: "Ошибка загрузки анкеты " + err)
                                                                                                  }), onCompleted: ({ [weak self] in
                                                                                                    self?.spinner?.hide()
                                                                                                    self?.navigationController?.popViewController(animated: true)
                                                                                                  }))
                                                   })))
        navBar.backgroundColor = UIColor(rgb: 0x2f5870)
        navBar.setBackButtonImage(image: UIImage(named: "back"))
        navBar.setFrontButtonImage(image: UIImage(named: "tick"))
        view.addSubview(navBar)
        navBar.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .bottom)
        self.navBar = navBar
    }
    
    private func setupSpinner() {
        let spinner = SpinnerView(frame: .zero)
        view.addSubview(spinner)
        
        view.bringSubviewToFront(spinner)
        spinner.autoPinEdgesToSuperviewEdges()
        self.spinner = spinner
    }
    
    private func alertError(reason: String) {
        let alert = UIAlertController(title: "Ошибка!", message: reason, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ок", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
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
                NSAttributedString.Key.font : UIFont.systemFont(ofSize: 20, weight: .medium)]
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
                NSAttributedString.Key.font : UIFont.systemFont(ofSize: 20, weight: .medium)]
                as [NSAttributedString.Key : Any]
            
            titleLabel?.attributedText = NSAttributedString(string: model, attributes: titleTextAttributes)
        }
    }
    
    private class TextFieldCell: UITableViewCell, UITextFieldDelegate {
        var resultText: String = ""
        var onUpdate: ((String) -> Void)?
        private var model: TextCellModel = TextCellModel(placeholder: "", text: "")
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
                NSAttributedString.Key.font : UIFont.systemFont(ofSize: 20, weight: .regular)]
                as [NSAttributedString.Key : Any]
            
            field.attributedPlaceholder = NSAttributedString(string: model.placeholder, attributes: textAttributes)
            field.text = model.text
            field.returnKeyType = .done
            field.delegate = self
            contentView.addSubview(field)
            field.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 32, left: 8, bottom: 8, right: 8))
            self.field = field
            field.addTarget(self, action: #selector(fieldChanged(_:)), for: .editingChanged)
        }
        
        @objc private func fieldChanged(_ sender: UITextField) {
            onUpdate?(sender.text ?? "")
        }
        
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            textField.resignFirstResponder()
            return true
        }
        
        func configure(model: TextCellModel, onUpdate: ((String) -> Void)?) {
            self.model = model
            self.onUpdate = onUpdate
            let textAttributes = [
                NSAttributedString.Key.foregroundColor : UIColor(rgb: 0x2f5870).withAlphaComponent(0.5),
                NSAttributedString.Key.font : UIFont.systemFont(ofSize: 20, weight: .regular)]
                as [NSAttributedString.Key : Any]
            
            field.attributedPlaceholder = NSAttributedString(string: model.placeholder, attributes: textAttributes)
            field.text = model.text
        }
    }
    
    private class LongTextFieldCell: UITableViewCell, UITextViewDelegate {
        var resultText: String = ""
        var onUpdate: ((String) -> Void)?
        private var parent: UITableView?
        private var model: TextCellModel = TextCellModel(placeholder: "", text: "")
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
            contentView.addSubview(field)
            field.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 32, left: 8, bottom: 8, right: 8))
            field.font = UIFont.systemFont(ofSize: 20)
            field.returnKeyType = .done
            self.field = field
            
            let placeholder = UILabel(frame: .zero)
            let textAttributes = [
                NSAttributedString.Key.foregroundColor : UIColor(rgb: 0x2f5870).withAlphaComponent(0.5),
                NSAttributedString.Key.font : UIFont.systemFont(ofSize: 20, weight: .regular)]
                as [NSAttributedString.Key : Any]
            
            placeholder.attributedText = NSAttributedString(string: model.placeholder, attributes: textAttributes)
            
            contentView.addSubview(placeholder)
            placeholder.autoPinEdge(toSuperviewEdge: .left, withInset: 16)
            placeholder.autoPinEdge(toSuperviewEdge: .top, withInset: 32 + 4)
            self.placeholder = placeholder
            
            field.text = model.text
            placeholder.isHidden = !model.text.isEmpty
            
            let textFieldAttributes = [
                NSAttributedString.Key.foregroundColor : UIColor(rgb: 0x2f5870),
                NSAttributedString.Key.font : UIFont.systemFont(ofSize: 20, weight: .medium)]
                as [NSAttributedString.Key : Any]
            
            let accessoryView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 40))
            accessoryView.backgroundColor = UIColor(rgb: 0xe5e5e5)
            let finishButton = UIButton(forAutoLayout: ())
            finishButton.setAttributedTitle(NSAttributedString(string: "Готово", attributes: textFieldAttributes), for: [])
            field.inputAccessoryView = accessoryView
            accessoryView.addSubview(finishButton)
            finishButton.addTarget(self, action: #selector(hideKeyboard), for: .touchUpInside)
            finishButton.autoPinEdge(toSuperviewEdge: .right, withInset: 16)
            finishButton.autoAlignAxis(toSuperviewAxis: .horizontal)
        }
        
        @objc private func hideKeyboard() {
            field.endEditing(true)
        }
        
        func textViewDidChange(_ textView: UITextView) {
            let size = textView.bounds.size
            let newSize = textView.sizeThatFits(CGSize(width: size.width, height: CGFloat.greatestFiniteMagnitude))
            onUpdate?(textView.text)
            if size.height != newSize.height {
                UIView.setAnimationsEnabled(false)
                parent?.beginUpdates()
                parent?.endUpdates()
                UIView.setAnimationsEnabled(true)
                
                if let thisIndexPath = parent?.indexPath(for: self) {
                    parent?.scrollToRow(at: thisIndexPath, at: .bottom, animated: false)
                }
            }
        }
        
        func textViewDidBeginEditing(_ textView: UITextView) {
            placeholder?.isHidden = true
        }
        
        func textViewDidEndEditing(_ textView: UITextView) {
            placeholder?.isHidden = (textView.text.count > 0)
        }
        
        func configure(model: TextCellModel, parent: UITableView?, onUpdate: ((String) -> Void)?) {
            self.model = model
            self.parent = parent
            self.onUpdate = onUpdate
            let textAttributes = [
                NSAttributedString.Key.foregroundColor : UIColor(rgb: 0x2f5870).withAlphaComponent(0.5),
                NSAttributedString.Key.font : UIFont.systemFont(ofSize: 20, weight: .regular)]
                as [NSAttributedString.Key : Any]
            
            placeholder?.attributedText = NSAttributedString(string: model.placeholder, attributes: textAttributes)
            field.text = model.text
            placeholder?.isHidden = !model.text.isEmpty
        }
    }
    
    private class ChooseCell: UITableViewCell {
        var chooseNumber: Int? = nil
        var onUpdate: ((Int?) -> Void)?
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
            let mainTextAttributes1 = [
                NSAttributedString.Key.foregroundColor : UIColor(rgb: 0x2f5870).withAlphaComponent(0.5),
                NSAttributedString.Key.font : UIFont.systemFont(ofSize: 20, weight: .regular)]
                as [NSAttributedString.Key : Any]
            
            let mainTextAttributes2 = [
                NSAttributedString.Key.foregroundColor : UIColor(rgb: 0x2f5870),
                NSAttributedString.Key.font : UIFont.systemFont(ofSize: 20, weight: .medium)]
                as [NSAttributedString.Key : Any]
            
            let mainButton = UIButton(forAutoLayout: ())
            if let ind = model.selectedIndex {
                mainButton.setAttributedTitle(NSAttributedString(string: model.options[ind], attributes: mainTextAttributes2), for: [])
            } else {
                mainButton.setAttributedTitle(NSAttributedString(string: model.title, attributes: mainTextAttributes1), for: [])
            }
            mainButton.contentHorizontalAlignment = .left
            contentView.addSubview(mainButton)
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
        
        func configure(model: ChooseCellModel, onUpdate: ((Int?) -> Void)?) {
            self.model = model
            self.onUpdate = onUpdate
            let mainTextAttributes1 = [
                NSAttributedString.Key.foregroundColor : UIColor(rgb: 0x2f5870).withAlphaComponent(0.5),
                NSAttributedString.Key.font : UIFont.systemFont(ofSize: 20, weight: .regular)]
                as [NSAttributedString.Key : Any]
            
            let mainTextAttributes2 = [
                NSAttributedString.Key.foregroundColor : UIColor(rgb: 0x2f5870),
                NSAttributedString.Key.font : UIFont.systemFont(ofSize: 20, weight: .medium)]
                as [NSAttributedString.Key : Any]
            
            if let ind = model.selectedIndex {
                mainButton.setAttributedTitle(NSAttributedString(string: model.options[ind], attributes: mainTextAttributes2), for: [])
            } else {
                mainButton.setAttributedTitle(NSAttributedString(string: model.title, attributes: mainTextAttributes1), for: [])
            }
        }
        
        @objc private func mainButtonTap(_ sender: UIButton) {
            let picker = ActionSheetMultipleStringPicker(title: model.title, rows: [model.options],
                                                         initialSelection: [model.selectedIndex ?? 0], doneBlock: { [weak self]
                    picker, values, indexes in
                    let textAttributes = [
                        NSAttributedString.Key.foregroundColor : UIColor(rgb: 0x2f5870),
                        NSAttributedString.Key.font : UIFont.systemFont(ofSize: 20, weight: .medium)]
                        as [NSAttributedString.Key : Any]
                    if let values = values,
                        let optionIndex = values.first as? Int,
                        let text = self?.model.options[optionIndex] {
                        self?.onUpdate?(optionIndex)
                        sender.setAttributedTitle(NSAttributedString(string: text, attributes: textAttributes), for: [])
                        self?.chooseNumber = optionIndex
                        return
                    }
                    self?.onUpdate?(nil)
                    return
                }, cancel: { ActionMultipleStringCancelBlock in return }, origin: sender)
            picker?.setTextColor(UIColor(rgb: 0x2f5870))
            
            let textAttributes = [
                NSAttributedString.Key.foregroundColor : UIColor(rgb: 0x2f5870),
                NSAttributedString.Key.font : UIFont.systemFont(ofSize: SizeDependent.instance.convertFont(16), weight: .medium)]
                as [NSAttributedString.Key : Any]
            
            let finishButton = UIButton(frame: CGRect(x: 0, y: 0, width: SizeDependent.instance.convertDimension(70), height: 35))
            finishButton.setAttributedTitle(NSAttributedString(string: "Готово", attributes: textAttributes), for: [])
            picker?.setDoneButton(UIBarButtonItem(customView: finishButton))
            
            let closeButton = UIButton(frame: CGRect(x: 0, y: 0, width: SizeDependent.instance.convertDimension(74), height: 35))
            closeButton.setAttributedTitle(NSAttributedString(string: "Закрыть", attributes: textAttributes), for: [])
            picker?.setCancelButton(UIBarButtonItem(customView: closeButton))
            picker?.show()
        }
    }
}
