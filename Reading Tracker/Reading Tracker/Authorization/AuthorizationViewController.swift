//
//  AuthorizationViewController.swift
//  Reading Tracker
//
//  Created by Andrei Kirilenko on 23.09.2018.
//  Copyright © 2018 Andrei Kirilenko. All rights reserved.
//

import UIKit
import PureLayout
import RxSwift
import Firebase

class AuthorizationViewController: UIViewController {
    private var greetingLabel: UILabel?
    private var authorizationForm: UIStackView?
    private var loginButton: UIButton?
    private var registerButton: UIButton?
    private var loginTextField: RTTextField?
    private var passwordTextField: RTTextField?
    private let loginTextFieldDelegate = LoginTextFieldDelegate()
    private let passwordTextFieldDelegate = PasswordTextFieldDelegate()
    var interactor: AuthorizationInteractor?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSubviews()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: ({
            UIView.animate(withDuration: 0.3, animations: ({ [weak self] in
                self?.greetingLabel?.alpha = 1
            }), completion: ({ _ in
                UIView.animate(withDuration: 0.3, animations: ({ [weak self] in
                    self?.authorizationForm?.alpha = 1
                    self?.registerButton?.alpha = 1
                }), completion: ({ _ in
                    UIView.animate(withDuration: 0.3, animations: ({ [weak self] in
                        self?.loginButton?.alpha = 1
                    }))
                }))
            }))
        }))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = true
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        view.backgroundColor = .orange
    }
    
    func alertError(description: String) {
        let alert = UIAlertController(title: "Ошибка!", message: description, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Повторить", style: .default, handler: ({ [weak self] _ in
            self?.tryLogin()
        })))
        alert.addAction(UIAlertAction(title: "Ок", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    private func setupSubviews() {
        setupGreeting()
        setupLoginButton()
        setupAuthorizationForm()
        setupRegisterButton()
    }
    
    private func setupRegisterButton() {
        guard let loginForm = authorizationForm else {
            return
        }
        
        let registerButton = UIButton(forAutoLayout: ())
        
        let buttonTextAttributes = [
            NSAttributedString.Key.foregroundColor : UIColor(rgb: 0x1f1f1f),
            NSAttributedString.Key.font : UIFont(name: "AvenirNext-Bold", size: 19.0)!]
            as [NSAttributedString.Key : Any]
        
        registerButton.setAttributedTitle(NSAttributedString(string: "Регистрация", attributes: buttonTextAttributes), for: .normal)
        registerButton.backgroundColor = UIColor(rgb: 0x75ff75)
        registerButton.layer.cornerRadius = 16
        registerButton.alpha = 0
        registerButton.addTarget(self, action: #selector(onRegisterButtonTapped), for: .touchUpInside)
        
        view.addSubview(registerButton)
        registerButton.autoPinEdge(.top, to: .bottom, of: loginForm, withOffset: 32)
        registerButton.autoSetDimensions(to: CGSize(width: 192, height: 32))
        registerButton.autoAlignAxis(toSuperviewAxis: .vertical)
        
        self.registerButton = registerButton
    }
    
    private func setupGreeting() {
        let greetingLabel = UILabel(forAutoLayout: ())
        greetingLabel.numberOfLines = 0
        greetingLabel.textAlignment = .center
        let greetingText = "Welcome to\nReading Tracker!"
        
        let textAttributes = [
            NSAttributedString.Key.foregroundColor : UIColor(rgb: 0x1f1f1f),
            NSAttributedString.Key.font : UIFont(name: "Chalkduster", size: 27.0)!]
            as [NSAttributedString.Key : Any]
        
        greetingLabel.attributedText = NSAttributedString(string: greetingText, attributes: textAttributes)
        greetingLabel.alpha = 0
        
        view.addSubview(greetingLabel)
        greetingLabel.autoAlignAxis(toSuperviewAxis: .vertical)
        greetingLabel.autoPinEdge(toSuperviewEdge: .top, withInset: 128)
        
        self.greetingLabel = greetingLabel
    }
    
    private func setupLoginButton() {
        let loginButton = UIButton(forAutoLayout: ())
        
        let buttonTextAttributes = [
            NSAttributedString.Key.foregroundColor : UIColor(rgb: 0x1f1f1f),
            NSAttributedString.Key.font : UIFont(name: "AvenirNext-Bold", size: 27.0)!]
            as [NSAttributedString.Key : Any]
        
        loginButton.setAttributedTitle(NSAttributedString(string: "Войти", attributes: buttonTextAttributes), for: .normal)
        loginButton.backgroundColor = UIColor(rgb: 0x75ff75)
        loginButton.layer.cornerRadius = 8
        loginButton.alpha = 0
        loginButton.addTarget(self, action: #selector(onLoginButtonTapped), for: .touchUpInside)
        
        view.addSubview(loginButton)
        loginButton.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 0, left: 16, bottom: 16, right: 16), excludingEdge: .top)
        loginButton.autoSetDimension(.height, toSize: 56)
        
        
        self.loginButton = loginButton
    }
    
    private func setupAuthorizationForm() {
        let formTextAttributes = [
            NSAttributedString.Key.foregroundColor : UIColor.black,
            NSAttributedString.Key.font : UIFont(name: "Georgia-BoldItalic", size: 19.0)!]
            as [NSAttributedString.Key : Any]
        
        let loginLabel = UILabel(forAutoLayout: ())
        loginLabel.attributedText = NSAttributedString(string: "Логин", attributes: formTextAttributes)
        
        let loginTextField = RTTextField()
        loginTextField.placeholder = "логин"
        loginTextField.layer.cornerRadius = 8
        loginTextField.backgroundColor = UIColor(rgb: 0xad5205)
        loginTextField.autocorrectionType = .no
        loginTextField.delegate = loginTextFieldDelegate
        loginTextField.returnKeyType = .continue
        
        let loginStackView = UIStackView(arrangedSubviews: [loginLabel, loginTextField])
        loginStackView.spacing = 8
        loginStackView.axis = .horizontal
        
        let passwordLabel = UILabel(forAutoLayout: ())
        passwordLabel.attributedText = NSAttributedString(string: "Пароль", attributes: formTextAttributes)
        
        let passwordTextField = RTTextField()
        passwordTextField.placeholder = "пароль"
        passwordTextField.layer.cornerRadius = 8
        passwordTextField.backgroundColor = UIColor(rgb: 0xad5205)
        passwordTextField.autocorrectionType = .no
        passwordTextField.isSecureTextEntry = true
        passwordTextField.delegate = passwordTextFieldDelegate
        passwordTextField.returnKeyType = .done
        loginTextFieldDelegate.nextField = passwordTextField
        
        let passwordStackView = UIStackView(arrangedSubviews: [passwordLabel, passwordTextField])
        passwordStackView.spacing = 8
        passwordStackView.axis = .horizontal
        
        let authorizationStackView = UIStackView(arrangedSubviews: [loginStackView, passwordStackView])
        authorizationStackView.spacing = 16
        authorizationStackView.axis = .vertical
        authorizationStackView.alpha = 0
        view.addSubview(authorizationStackView)
        
        loginTextField.autoSetDimensions(to: CGSize(width: 192, height: 32))
        passwordTextField.autoSetDimensions(to: CGSize(width: 192, height: 32))
        authorizationStackView.autoCenterInSuperview()
        
        self.loginTextField = loginTextField
        self.passwordTextField = passwordTextField
        self.authorizationForm = authorizationStackView
    }
    
    private class LoginTextFieldDelegate: NSObject, UITextFieldDelegate {
        var nextField: UITextField?
        
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            nextField?.becomeFirstResponder()
            return true
        }
        
        func textFieldDidEndEditing(_ textField: UITextField) {
            //TODO: check corectness
        }
    }
    
    private class PasswordTextFieldDelegate: NSObject, UITextFieldDelegate {
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            textField.resignFirstResponder()
            return true
        }
        
        func textFieldDidEndEditing(_ textField: UITextField) {
            //TODO: check corectness
        }
    }
    
    @objc private func onLoginButtonTapped() {
        tryLogin()
    }
    
    @objc private func onRegisterButtonTapped() {
        navigationController?.pushViewController(RegistrationViewController(), animated: true)
    }
    
    private func tryLogin() {
        guard let loginText = loginTextField?.text,
            let passwordText = passwordTextField?.text else {
                return
        }
        
        interactor?.loginButtonTapped(login: loginText, password: passwordText)
    }
}
