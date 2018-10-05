//
//  RegistrationViewController.swift
//  Reading Tracker
//
//  Created by Andrei Kirilenko on 27.09.2018.
//  Copyright © 2018 Andrei Kirilenko. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class RegistrationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let fields: [String] = ["Логин", "Пароль", "Подтверждение пароля", "ФИО", "Пол", "Дата рождения", "Образование", "Любимые авторы/книги", "Семейное положение", "Любимый формат книги"]
    var fieldValue: [Int: String] = [:]
    var tableView: UITableView!
    var finishButton: UIButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupRegisterButton()
    }
    
    private func setupTableView() {
        tableView = UITableView(forAutoLayout: ())
        view.addSubview(tableView)
        view.backgroundColor = .orange
        tableView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 64, left: 0, bottom: 96, right: 0))
        tableView.register(RTRegistrationTextCell.self, forCellReuseIdentifier: "cell")
        tableView.tableFooterView = UIView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .orange
        tableView.separatorInset = .zero
        tableView.separatorColor = .darkGray
    }
    
    private func setupRegisterButton() {
        let finishButton = UIButton(forAutoLayout: ())
        
        let buttonTextAttributes = [
            NSAttributedString.Key.foregroundColor : UIColor(rgb: 0x1f1f1f),
            NSAttributedString.Key.font : UIFont(name: "AvenirNext-Bold", size: 27.0)!]
            as [NSAttributedString.Key : Any]
        
        finishButton.setAttributedTitle(NSAttributedString(string: "Завершить", attributes: buttonTextAttributes), for: .normal)
        finishButton.backgroundColor = UIColor(rgb: 0x75ff75)
        finishButton.layer.cornerRadius = 8
        finishButton.addTarget(self, action: #selector(onFinishButtonTapped), for: .touchUpInside)
        
        view.addSubview(finishButton)
        finishButton.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 0, left: 16, bottom: 16, right: 16), excludingEdge: .top)
        finishButton.autoSetDimension(.height, toSize: 56)
        
        
        self.finishButton = finishButton
    }
    
    @objc private func onFinishButtonTapped() {
        guard validateFields() else {
            return
        }
        
        let login = fieldValue[0] ?? ""
        let password = fieldValue[1] ?? ""
        
        Auth.auth().createUser(withEmail: login, password: password) { (authResult, errorRaw) in
            let errorClosure = { (text: String) in
                let alert = UIAlertController(title: "Ошибка!", message: text, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ок", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            if let error = errorRaw {
                errorClosure(error.localizedDescription)
                return
            }
            
            guard let uid = authResult?.user.uid else {
                errorClosure("Auth error occurred")
                return
            }
            
            //let db = Firestore.firestore()
         }
        //Auth.auth().currentUser?.createProfileChangeRequest().commitChanges(completion: nil)
    }
    
    private func validateFields() -> Bool {
        let errorClosure = { (text: String) in
            let alert = UIAlertController(title: "Ошибка!", message: text, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ок", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
        guard fieldValue.count == fields.count else {
            errorClosure("Не все поля заполнены")
            return false
        }
        
        /*for index in 0..<fields.count {
            if let value = fieldValue[index],
                value.isEmpty {
                errorClosure("Не все поля заполнены")
                return false
            }
        }*/
        
        if let password = fieldValue[1],
           let confirm = fieldValue[2],
            password != confirm {
            errorClosure("Пароли не совпадают")
        }
        
        return true
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.fields.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: RTRegistrationTextCell = self.tableView.dequeueReusableCell(withIdentifier: "cell") as! RTRegistrationTextCell
        cell.configure(model: RTTextCellModel(placeholder: fields[indexPath.row], index: indexPath.row, onCompleted: ({ [weak self] text, index in
            self?.fieldValue[index] = text
        })))
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
    
    override func viewWillAppear(_ animated: Bool) {
    }
}

struct RTTextCellModel {
    var placeholderText: String
    var index: Int
    var onCompleted: ((String, Int) -> Void)?
    
    init(placeholder: String, index: Int, onCompleted: ((String, Int) -> Void)?) {
        self.placeholderText = placeholder
        self.index = index
        self.onCompleted = onCompleted
    }
}

private class RTRegistrationTextCell: UITableViewCell {
    private var model: RTTextCellModel = RTTextCellModel(placeholder: "", index: 0, onCompleted: nil)
    private var textField: UITextField?
    private let textFieldDelegate = CellTextFieldDelegate()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .orange
        
        setupSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupSubviews() {
        let textField = RTTextField(frame: .zero)
        textField.placeholder = model.placeholderText
        textField.returnKeyType = .done
        addSubview(textField)
        textField.autoPinEdgesToSuperviewEdges()
        textField.autoSetDimension(.height, toSize: 48)
        textFieldDelegate.onCompleted = { [weak self] text in
            guard let strongSelf = self else {
                return
            }
            
            strongSelf.model.onCompleted?(text, strongSelf.model.index)
        }
        textField.delegate = textFieldDelegate
        textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        self.textField = textField
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        model.onCompleted?(textField.text ?? "", model.index)
    }
    
    func configure(model: RTTextCellModel) {
        self.model = model
        textField?.placeholder = model.placeholderText
    }
    
    private class CellTextFieldDelegate: NSObject, UITextFieldDelegate {
        var onCompleted: ((String) -> Void)?
        
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            textField.resignFirstResponder()
            onCompleted?(textField.text ?? "")
            return true
        }
        
        func textFieldDidEndEditing(_ textField: UITextField) {
            onCompleted?(textField.text ?? "")
        }
    }
}
