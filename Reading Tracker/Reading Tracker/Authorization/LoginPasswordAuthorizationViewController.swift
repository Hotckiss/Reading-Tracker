//
//  LoginPasswordAuthorizationViewController.swift
//  Reading Tracker
//
//  Created by Andrei Kirilenko on 04/11/2018.
//  Copyright © 2018 Andrei Kirilenko. All rights reserved.
//

import UIKit
import PureLayout
import RxSwift
import Firebase

class LoginPasswordAuthorizationViewController: UIViewController {
    private var spinner: UIActivityIndicatorView?
    private var emailTextField: RTTextField?
    private var passwordTextField: RTTextField?
    private let emailTextFieldDelegate = IntermediateTextFieldDelegate()
    private let passwordTextFieldDelegate = FinishTextFieldDelegate()
    private var codeButtonBottomConstraint: NSLayoutConstraint?
    
    deinit {
        NotificationCenter.default.removeObserver(UIResponder.keyboardWillShowNotification)
        NotificationCenter.default.removeObserver(UIResponder.keyboardWillHideNotification)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        setupSubviews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = true
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        view.backgroundColor = .white
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            codeButtonBottomConstraint?.constant = -(keyboardSize.height + 16)
        }
        
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        codeButtonBottomConstraint?.constant = -100
    }
    
    private func setupSubviews() {
        let navBar = NavigationBar(frame: .zero)
        navBar.configure(model: NavigationBarModel(title: "Вход",
                                                   backButtonText: "Назад",
                                                   onBackButtonPressed: ({ [weak self] in
                                                    self?.navigationController?.popViewController(animated: true)
                                                   })
        ))
        navBar.backgroundColor = UIColor(rgb: 0x2f5870)
        view.addSubview(navBar)
        navBar.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .bottom)
        
        let spinner = UIActivityIndicatorView()
        view.addSubview(spinner)
        
        spinner.autoCenterInSuperview()
        spinner.backgroundColor = UIColor(rgb: 0xad5205).withAlphaComponent(0.7)
        spinner.layer.cornerRadius = 8
        spinner.autoSetDimensions(to: CGSize(width: 64, height: 64))
        self.spinner = spinner
        
        let placeholderTextAttributes = [
            NSAttributedString.Key.foregroundColor : UIColor(rgb: 0x2f5870),
            NSAttributedString.Key.font : UIFont(name: "Avenir-Light", size: 20.0)!]
            as [NSAttributedString.Key : Any]
        
        let emailTextField = RTTextField(padding: .zero)
        emailTextField.attributedPlaceholder = NSAttributedString(string: "Адрес электронной почты", attributes: placeholderTextAttributes)
        emailTextField.backgroundColor = .clear
        emailTextField.autocorrectionType = .no
        emailTextField.delegate = emailTextFieldDelegate
        emailTextField.returnKeyType = .continue
        
        view.addSubview(emailTextField)
        emailTextField.autoAlignAxis(toSuperviewAxis: .vertical)
        emailTextField.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 150, left: 16, bottom: 0, right: 0), excludingEdge: .bottom)
        
        self.emailTextField = emailTextField
        
        let lineView = UIView(frame: .zero)
        lineView.backgroundColor = UIColor(rgb: 0x2f5870)
        
        view.addSubview(lineView)
        lineView.autoPinEdge(.top, to: .bottom, of: emailTextField, withOffset: 8)
        lineView.autoPinEdge(toSuperviewEdge: .left, withInset: 16)
        lineView.autoPinEdge(toSuperviewEdge: .right, withInset: 16)
        lineView.autoSetDimension(.height, toSize: 1)
        
        let passwordTextField = RTTextField(padding: .zero)
        passwordTextField.attributedPlaceholder = NSAttributedString(string: "Пароль", attributes: placeholderTextAttributes)
        passwordTextField.backgroundColor = .clear
        passwordTextField.autocorrectionType = .no
        passwordTextField.delegate = passwordTextFieldDelegate
        passwordTextField.returnKeyType = .done
        emailTextFieldDelegate.nextField = passwordTextField
        passwordTextField.isSecureTextEntry = true
        view.addSubview(passwordTextField)
        passwordTextField.autoAlignAxis(toSuperviewAxis: .vertical)
        passwordTextField.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 150 + 84, left: 16, bottom: 0, right: 16 + 22), excludingEdge: .bottom)
        
        let eyeButton = UIButton(forAutoLayout: ())
        eyeButton.setImage(UIImage(named: "eye"), for: [])
        eyeButton.addTarget(self, action: #selector(onEyeButtonPressed), for: UIControl.Event.touchDown)
        
        eyeButton.addTarget(self, action: #selector(onEyeButtonUnpressed), for: UIControl.Event.touchUpInside)
        view.addSubview(eyeButton)
        
        eyeButton.autoSetDimensions(to: CGSize(width: 22, height: 19))
        eyeButton.autoPinEdge(.left, to: .right, of: passwordTextField, withOffset: 2)
        eyeButton.autoPinEdge(.top, to: .top, of: passwordTextField, withOffset: 4)
        eyeButton.autoPinEdge(toSuperviewEdge: .right, withInset: 16)
        
        self.passwordTextField = passwordTextField
        
        let lineView2 = UIView(frame: .zero)
        lineView2.backgroundColor = UIColor(rgb: 0x2f5870)
        
        view.addSubview(lineView2)
        lineView2.autoPinEdge(.top, to: .bottom, of: passwordTextField, withOffset: 8)
        lineView2.autoPinEdge(toSuperviewEdge: .left, withInset: 16)
        lineView2.autoPinEdge(toSuperviewEdge: .right, withInset: 16)
        lineView2.autoSetDimension(.height, toSize: 1)
        
        let activateButton = UIButton(frame: .zero)
        
        let buttonTextAttributes = [
            NSAttributedString.Key.foregroundColor : UIColor.white,
            NSAttributedString.Key.font : UIFont(name: "Avenir-Medium", size: 20.0)!]
            as [NSAttributedString.Key : Any]
        
        activateButton.setAttributedTitle(NSAttributedString(string: "Войти", attributes: buttonTextAttributes), for: .normal)
        activateButton.backgroundColor = UIColor(rgb: 0x2f5870)
        activateButton.layer.cornerRadius = 32
        activateButton.layer.shadowRadius = 4
        activateButton.layer.shadowColor = UIColor(rgb: 0x2f5870).cgColor
        activateButton.layer.shadowOpacity = 0.33
        activateButton.layer.shadowOffset = CGSize(width: 0.0, height: 4.0)
        activateButton.addTarget(self, action: #selector(onActivateButtonTapped), for: .touchUpInside)
        view.addSubview(activateButton)
        codeButtonBottomConstraint = activateButton.autoPinEdge(toSuperviewEdge: .bottom, withInset: 100)
        activateButton.autoSetDimensions(to: CGSize(width: 295, height: 64))
        activateButton.autoAlignAxis(toSuperviewAxis: .vertical)
        
    }
    
    @objc private func onEyeButtonPressed() {
        passwordTextField?.isSecureTextEntry = false
    }
    
    @objc private func onEyeButtonUnpressed() {
        passwordTextField?.isSecureTextEntry = true
    }
    
    @objc private func onActivateButtonTapped() {
        let email = emailTextField?.text ?? ""
        let password = passwordTextField?.text ?? ""
        self.spinner?.startAnimating()
        
        Auth.auth().signIn(withEmail: email, password: password) { (authResult, errorRaw) in
            let errorClosure = { (text: String) in
                let alert = UIAlertController(title: "Ошибка!", message: text, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ок", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            
            
            if let error = errorRaw {
                self.spinner?.stopAnimating()
                errorClosure(error.localizedDescription)
                return
            }
            
            if let user = authResult {
                //todo: upload ALL info
                self.spinner?.stopAnimating()
                self.navigationController?.popToRootViewController(animated: false)
            }
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
    }
}



