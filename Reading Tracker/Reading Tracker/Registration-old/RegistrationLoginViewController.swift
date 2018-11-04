//
//  RagistrationLoginViewController.swift
//  Reading Tracker
//
//  Created by Andrei Kirilenko on 07.10.2018.
//  Copyright © 2018 Andrei Kirilenko. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class RegistrationLoginViewController: UIViewController {
    var interactor: RegistrationInteractor?
    
    private var loginTextField: RTTextField?
    private var passwordTextField: RTTextField?
    private var confirmTextField: RTTextField?
    private var finishButton: UIButton?
    private var finishButtonBottomConstraint: NSLayoutConstraint?
    
    private let loginTextFieldDelegate = IntermediateTextFieldDelegate()
    private let passwordTextFieldDelegate = IntermediateTextFieldDelegate()
    private let confirmTextFieldDelegate = FinishTextFieldDelegate()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(rgb: 0x232f6d)
        setupSubviews()
        setupFinishButton()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(UIResponder.keyboardWillShowNotification)
        NotificationCenter.default.removeObserver(UIResponder.keyboardWillHideNotification)
    }
    
    private func setupSubviews() {
        let navBar = NavigationBar(frame: .zero)
        navBar.configure(model: NavigationBarModel(title: "Регистрация",
                                                   backButtonText: "Назад",
                                                   frontButtonText: "Сбросить",
                                                   onBackButtonPressed: ({ [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }),                                        onFrontButtonPressed: ({
            let alert = UIAlertController(title: "Сбросить", message: "Очистить поля?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Отмена", style: .default, handler: nil))
            alert.addAction(UIAlertAction(title: "Да", style: .destructive, handler: ({ _ in
                RegistrationDraft.registrationDraftInstance.setLogin(login: "")
                RegistrationDraft.registrationDraftInstance.setPassword(password: "")
                self.loginTextField?.text = ""
                self.passwordTextField?.text = ""
                self.confirmTextField?.text = ""
                self.updateFinishButton()
            })))
            self.present(alert, animated: true, completion: nil)
        })))
        
        let loginTextField = RTTextField()
        loginTextField.placeholder = "логин"
        loginTextField.backgroundColor = UIColor(rgb: 0xad5205).withAlphaComponent(0.3)
        loginTextField.autocorrectionType = .no
        loginTextField.delegate = loginTextFieldDelegate
        loginTextField.returnKeyType = .continue
        loginTextField.text = RegistrationDraft.registrationDraftInstance.getLogin()
        
        let passwordTextField = RTTextField()
        passwordTextField.placeholder = "пароль"
        passwordTextField.backgroundColor = UIColor(rgb: 0xad5205).withAlphaComponent(0.3)
        passwordTextField.autocorrectionType = .no
        //passwordTextField.isSecureTextEntry = true
        passwordTextField.delegate = passwordTextFieldDelegate
        passwordTextField.returnKeyType = .continue
        loginTextFieldDelegate.nextField = passwordTextField
        
        let confirmTextField = RTTextField()
        confirmTextField.placeholder = "подтверждение пароля"
        confirmTextField.backgroundColor = UIColor(rgb: 0xad5205).withAlphaComponent(0.3)
        confirmTextField.autocorrectionType = .no
        //confirmTextField.isSecureTextEntry = true
        confirmTextField.delegate = confirmTextFieldDelegate
        confirmTextField.returnKeyType = .done
        passwordTextFieldDelegate.nextField = confirmTextField
        
        view.addSubview(navBar)
        view.addSubview(loginTextField)
        view.addSubview(passwordTextField)
        view.addSubview(confirmTextField)
        
        navBar.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: UIApplication.shared.statusBarFrame.height, left: 0, bottom: 0, right: 0), excludingEdge: .bottom)
        
        loginTextField.autoPinEdge(toSuperviewEdge: .left)
        loginTextField.autoPinEdge(toSuperviewEdge: .right)
        loginTextField.autoPinEdge(.top, to: .bottom, of: navBar, withOffset: 24)
        loginTextField.autoSetDimension(.height, toSize: 48)
        
        passwordTextField.autoPinEdge(toSuperviewEdge: .left)
        passwordTextField.autoPinEdge(toSuperviewEdge: .right)
        passwordTextField.autoPinEdge(.top, to: .bottom, of: loginTextField, withOffset: 24)
        passwordTextField.autoSetDimension(.height, toSize: 48)
        
        confirmTextField.autoPinEdge(toSuperviewEdge: .left)
        confirmTextField.autoPinEdge(toSuperviewEdge: .right)
        confirmTextField.autoPinEdge(.top, to: .bottom, of: passwordTextField, withOffset: 24)
        confirmTextField.autoSetDimension(.height, toSize: 48)
        
        self.loginTextField = loginTextField
        self.passwordTextField = passwordTextField
        self.confirmTextField = confirmTextField
        
        loginTextField.addTarget(self, action: #selector(loginTextFieldDidChange(_:)), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(passwordTextFieldDidChange(_:)), for: .editingChanged)
        confirmTextField.addTarget(self, action: #selector(confirmTextFieldDidChange(_:)), for: .editingChanged)
    }
    
    private func setupFinishButton() {
        let finishButton = UIButton(forAutoLayout: ())
        
        let buttonTextAttributes = [
            NSAttributedString.Key.foregroundColor : UIColor(rgb: 0x1f1f1f),
            NSAttributedString.Key.font : UIFont(name: "AvenirNext-Bold", size: 27.0)!]
            as [NSAttributedString.Key : Any]
        
        finishButton.setAttributedTitle(NSAttributedString(string: "Далее", attributes: buttonTextAttributes), for: .normal)
        finishButton.backgroundColor = UIColor(rgb: 0x75ff75)
        finishButton.layer.borderColor = UIColor(rgb: 0x1f1f1f).cgColor
        finishButton.layer.cornerRadius = 8
        finishButton.addTarget(self, action: #selector(onFinishButtonTapped), for: .touchUpInside)
        finishButton.isUserInteractionEnabled = false
        
        view.addSubview(finishButton)
        finishButtonBottomConstraint = finishButton.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 0, left: 16, bottom: 16, right: 16), excludingEdge: .top)[1]
        
        finishButton.autoSetDimension(.height, toSize: 56)
        
        self.finishButton = finishButton
        updateFinishButton()
    }
    
    
    @objc func keyboardWillShow(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if let conatant = finishButtonBottomConstraint?.constant,
                conatant == CGFloat(-16) {
            finishButtonBottomConstraint?.constant -= keyboardSize.height
            }
        }
        
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        finishButtonBottomConstraint?.constant = -16
    }
    
    @objc private func onFinishButtonTapped() {
        let vc = RegistrationAboutSelfViewController()
        vc.interactor = interactor
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func loginTextFieldDidChange(_ textField: UITextField) {
        RegistrationDraft.registrationDraftInstance.setLogin(login: textField.text ?? "")
    }
    
    @objc func passwordTextFieldDidChange(_ textField: UITextField) {
        RegistrationDraft.registrationDraftInstance.setPassword(password: textField.text ?? "")
        updateFinishButton()
    }
    
    @objc func confirmTextFieldDidChange(_ textField: UITextField) {
        updateFinishButton()
    }
    
    private func updateFinishButton() {
        guard let password = passwordTextField?.text,
            let confirmation = confirmTextField?.text else {
                return
        }
        
        if !password.isEmpty && password == confirmation {
            finishButton?.layer.borderWidth = 0
            finishButton?.backgroundColor = UIColor(rgb: 0x75ff75)
            finishButton?.isUserInteractionEnabled = true
        } else {
            finishButton?.layer.borderWidth = 2
            finishButton?.backgroundColor = .clear
            finishButton?.isUserInteractionEnabled = false
        }
    }
    
    private class IntermediateTextFieldDelegate: NSObject, UITextFieldDelegate {
        var nextField: UITextField?
        
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            nextField?.becomeFirstResponder()
            return true
        }
    }
    
    private class FinishTextFieldDelegate: NSObject, UITextFieldDelegate {
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            textField.resignFirstResponder()
            return true
        }
        
        func textFieldDidEndEditing(_ textField: UITextField) {
            //TODO: check corectness
        }
    }
}
