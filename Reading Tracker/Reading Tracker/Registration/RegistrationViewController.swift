//
//  RegistrationViewController.swift
//  Reading Tracker
//
//  Created by Andrei Kirilenko on 04/11/2018.
//  Copyright © 2018 Andrei Kirilenko. All rights reserved.
//

import UIKit
import PureLayout
import RxSwift
import Firebase

class RegistrationViewController: UIViewController {
    private let disposeBag = DisposeBag()
    
    private var spinner: UIActivityIndicatorView?
    private var greetingLabel: UILabel?
    private var loginButton: UIButton?
    private var registerButton: UIButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubviews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = true
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
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
        
        let spinner = UIActivityIndicatorView()
        
        view.addSubview(spinner)
        
        spinner.autoCenterInSuperview()
        spinner.backgroundColor = UIColor(rgb: 0xad5205).withAlphaComponent(0.7)
        spinner.layer.cornerRadius = 8
        spinner.autoSetDimensions(to: CGSize(width: 64, height: 64))
        self.spinner = spinner
    }
    
    private func setupRegisterButton() {
        guard let greetingLabel = greetingLabel else {
            return
        }
        
        let registerButton = UIButton(forAutoLayout: ())
        
        let buttonTextAttributes = [
            NSAttributedString.Key.foregroundColor : UIColor(rgb: 0x2f5870),
            NSAttributedString.Key.font : UIFont(name: "Avenir-Medium", size: 24.0)!]
            as [NSAttributedString.Key : Any]
        
        registerButton.setAttributedTitle(NSAttributedString(string: "Код участника", attributes: buttonTextAttributes), for: .normal)
        registerButton.backgroundColor = .white
        registerButton.layer.cornerRadius = 32
        registerButton.addTarget(self, action: #selector(onRegisterButtonTapped), for: .touchUpInside)
        
        view.addSubview(registerButton)
        registerButton.autoPinEdge(.top, to: .bottom, of: greetingLabel, withOffset: 170)
        registerButton.autoSetDimensions(to: CGSize(width: 223, height: 64))
        registerButton.autoAlignAxis(toSuperviewAxis: .vertical)
        
        self.registerButton = registerButton
    }
    
    private func setupGreeting() {
        let greetingLabel = UILabel(forAutoLayout: ())
        greetingLabel.numberOfLines = 0
        greetingLabel.textAlignment = .center
        let greetingText = "Дневник\nчитателя"
        
        let textAttributes = [
            NSAttributedString.Key.foregroundColor : UIColor.white,
            NSAttributedString.Key.font : UIFont(name: "BradleyHandITCTT-Bold", size: 64.0)!]
            as [NSAttributedString.Key : Any]
        
        greetingLabel.attributedText = NSAttributedString(string: greetingText, attributes: textAttributes)
        view.addSubview(greetingLabel)
        greetingLabel.autoAlignAxis(toSuperviewAxis: .vertical)
        greetingLabel.autoPinEdge(toSuperviewEdge: .top, withInset: 70)
        
        self.greetingLabel = greetingLabel
    }
    
    private func setupLoginButton() {
        guard let registerButton = registerButton else {
            return
        }
        
        let loginButton = UIButton(forAutoLayout: ())
        
        let buttonTextAttributes = [
            NSAttributedString.Key.foregroundColor : UIColor.white,
            NSAttributedString.Key.font : UIFont(name: "Avenir-Medium", size: 20.0)!]
            as [NSAttributedString.Key : Any]
        
        loginButton.setAttributedTitle(NSAttributedString(string: "Логин и пароль", attributes: buttonTextAttributes), for: .normal)
        loginButton.backgroundColor = UIColor(rgb: 0x2f5870)
        loginButton.layer.cornerRadius = 32
        loginButton.layer.borderColor = UIColor.white.cgColor
        loginButton.layer.borderWidth = 1
        loginButton.addTarget(self, action: #selector(onLoginButtonTapped), for: .touchUpInside)
        
        view.addSubview(loginButton)
        loginButton.autoPinEdge(.top, to: .bottom, of: registerButton, withOffset: 40)
        loginButton.autoSetDimensions(to: CGSize(width: 225, height: 64))
        loginButton.autoAlignAxis(toSuperviewAxis: .vertical)
        
        self.loginButton = loginButton
    }
    
    @objc private func onLoginButtonTapped() {
    }
    
    @objc private func onRegisterButtonTapped() {
    }
}
