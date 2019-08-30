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
    private let disposeBag = DisposeBag()
    
    private var spinner: SpinnerView?
    private var greetingImage: UIImageView?
    //private var authorizationForm: UIStackView?
    private var loginButton: UIButton?
    private var registerButton: UIButton?
    //private var loginTextField: RTTextField?
    //private var passwordTextField: RTTextField?
    //private let loginTextFieldDelegate = LoginTextFieldDelegate()
    //private let passwordTextFieldDelegate = PasswordTextFieldDelegate()
    var interactor: AuthorizationInteractor?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSubviews()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: ({
            UIView.animate(withDuration: 0.3, animations: ({ [weak self] in
                self?.greetingImage?.alpha = 1
                self?.loginButton?.alpha = 1
                self?.registerButton?.alpha = 1
            }))
        }))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = true
        view.backgroundColor = UIColor(rgb: 0x2f5870)
    }
    
    /*func alertError(description: String) {
        let alert = UIAlertController(title: "Ошибка!", message: description, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Повторить", style: .default, handler: ({ [weak self] _ in
            self?.tryLogin()
        })))
        alert.addAction(UIAlertAction(title: "Ок", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }*/

    private func setupSubviews() {
        setupGreeting()
        setupRegisterButton()
        setupLoginButton()
        
        setupSpinner()
    }
    
    private func setupSpinner() {
        let spinner = SpinnerView(frame: .zero)
        view.addSubview(spinner)
        
        view.bringSubviewToFront(spinner)
        spinner.autoPinEdgesToSuperviewEdges()
        self.spinner = spinner
    }
    
    private func setupRegisterButton() {
        guard let greetingImage = greetingImage else {
            return
        }
        
        let registerButton = UIButton(forAutoLayout: ())
        
        let buttonTextAttributes = [
            NSAttributedString.Key.foregroundColor : UIColor(rgb: 0x2f5870),
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: 24, weight: .medium)]
            as [NSAttributedString.Key : Any]
        
        registerButton.setAttributedTitle(NSAttributedString(string: "Регистрация", attributes: buttonTextAttributes), for: .normal)
        registerButton.backgroundColor = .white
        registerButton.layer.cornerRadius = 32
        registerButton.alpha = 0
        registerButton.addTarget(self, action: #selector(onRegisterButtonTapped), for: .touchUpInside)
        
        view.addSubview(registerButton)
        registerButton.autoPinEdge(.top, to: .bottom, of: greetingImage, withOffset: SizeDependent.instance.convertPadding(115))
        registerButton.autoSetDimensions(to: CGSize(width: 243, height: 64))
        registerButton.autoAlignAxis(toSuperviewAxis: .vertical)
        
        self.registerButton = registerButton
    }
    
    private func setupGreeting() {
        let greetingImage = UIImageView(forAutoLayout: ())
        greetingImage.image = UIImage(named: "titleImage")
        
        view.addSubview(greetingImage)
        greetingImage.autoSetDimensions(to: CGSize(width: 312, height: 156))
        greetingImage.autoAlignAxis(toSuperviewAxis: .vertical)
        greetingImage.autoPinEdge(toSuperviewEdge: .top, withInset: SizeDependent.instance.convertPadding(70))
        
        self.greetingImage = greetingImage
    }
    
    private func setupLoginButton() {
        guard let registerButton = registerButton else {
            return
        }
        
        let loginButton = UIButton(forAutoLayout: ())
        
        let buttonTextAttributes = [
            NSAttributedString.Key.foregroundColor : UIColor.white,
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: 24, weight: .medium)]
            as [NSAttributedString.Key : Any]
        
        loginButton.setAttributedTitle(NSAttributedString(string: "Войти", attributes: buttonTextAttributes), for: .normal)
        loginButton.backgroundColor = UIColor(rgb: 0x2f5870)
        loginButton.layer.cornerRadius = 32
        loginButton.layer.borderColor = UIColor.white.cgColor
        loginButton.layer.borderWidth = 1
        loginButton.alpha = 0
        loginButton.addTarget(self, action: #selector(onLoginButtonTapped), for: .touchUpInside)
        
        view.addSubview(loginButton)
        loginButton.autoPinEdge(.top, to: .bottom, of: registerButton, withOffset: SizeDependent.instance.convertPadding(40))
        loginButton.autoSetDimensions(to: CGSize(width: 144, height: 64))
        loginButton.autoAlignAxis(toSuperviewAxis: .vertical)
        
        self.loginButton = loginButton
    }
    
    /*private func setupAuthorizationForm() {
        let formTextAttributes = [
            NSAttributedString.Key.foregroundColor : UIColor.black,
            NSAttributedString.Key.font : UIFont(name: "Georgia-BoldItalic", size: 19.0)!]
            as [NSAttributedString.Key : Any]
        
        let loginLabel = UILabel(forAutoLayout: ())
        loginLabel.attributedText = NSAttributedString(string: "Логин", attributes: formTextAttributes)
        
        let loginTextField = RTTextField()
        loginTextField.placeholder = "логин"
        loginTextField.layer.cornerRadius = 8
        loginTextField.backgroundColor = UIColor(rgb: 0xad5205).withAlphaComponent(0.3)
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
        passwordTextField.backgroundColor = UIColor(rgb: 0xad5205).withAlphaComponent(0.3)
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
    }*/
    
    @objc private func onLoginButtonTapped() {
        let vc = LoginPasswordAuthorizationViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func onRegisterButtonTapped() {
        let vc = LoginPasswordRegistrationViewController()
        navigationController?.pushViewController(vc, animated: true)
        //let vc = RegistrationViewController()
        //navigationController?.pushViewController(vc, animated: true)
    }
}
