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
import GoogleSignIn

class RegistrationViewController: UIViewController, GIDSignInUIDelegate {
    private let disposeBag = DisposeBag()
    
    private var spinner: UIActivityIndicatorView?
    private var greetingLabel: UILabel?
    private var loginButton: UIButton?
    private var codeButton: UIButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance().uiDelegate = self
        setupSubviews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = true
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        view.backgroundColor = UIColor(rgb: 0x2f5870)
    }
    
    private func setupSubviews() {
        setupGreeting()
        setupRegisterButton()
        setupLoginButton()
        setupSignInButtons()
        
        let spinner = UIActivityIndicatorView()
        
        view.addSubview(spinner)
        
        spinner.autoCenterInSuperview()
        spinner.backgroundColor = UIColor(rgb: 0xad5205).withAlphaComponent(0.7)
        spinner.layer.cornerRadius = 8
        spinner.autoSetDimensions(to: CGSize(width: 64, height: 64))
        self.spinner = spinner
    }
    
    private func setupSignInButtons() {
        guard let greetingLabel = greetingLabel else {
            return
        }
        
        let signInButtonGoogle: GIDSignInButton = GIDSignInButton(forAutoLayout: ())
        signInButtonGoogle.style = GIDSignInButtonStyle.iconOnly
        
        let stackView = UIStackView(arrangedSubviews: [signInButtonGoogle])
        stackView.spacing = 20
        stackView.axis = .horizontal
        view.addSubview(stackView)
        
        stackView.autoAlignAxis(toSuperviewAxis: .vertical)
        stackView.autoPinEdge(.top, to: .bottom, of: greetingLabel, withOffset: 77)
    }
    
    private func setupRegisterButton() {
        guard let greetingLabel = greetingLabel else {
            return
        }
        
        let codeButton = UIButton(forAutoLayout: ())
        
        let buttonTextAttributes = [
            NSAttributedString.Key.foregroundColor : UIColor(rgb: 0x2f5870),
            NSAttributedString.Key.font : UIFont(name: "Avenir-Medium", size: 24.0)!]
            as [NSAttributedString.Key : Any]
        
        codeButton.setAttributedTitle(NSAttributedString(string: "Код участника", attributes: buttonTextAttributes), for: .normal)
        codeButton.backgroundColor = .white
        codeButton.layer.cornerRadius = 32
        codeButton.addTarget(self, action: #selector(onRegisterButtonTapped), for: .touchUpInside)
        
        view.addSubview(codeButton)
        codeButton.autoPinEdge(.top, to: .bottom, of: greetingLabel, withOffset: 170)
        codeButton.autoSetDimensions(to: CGSize(width: 223, height: 64))
        codeButton.autoAlignAxis(toSuperviewAxis: .vertical)
        
        self.codeButton = codeButton
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
        guard let codeButton = codeButton else {
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
        loginButton.autoPinEdge(.top, to: .bottom, of: codeButton, withOffset: 40)
        loginButton.autoSetDimensions(to: CGSize(width: 225, height: 64))
        loginButton.autoAlignAxis(toSuperviewAxis: .vertical)
        
        self.loginButton = loginButton
    }
    
    @objc private func onLoginButtonTapped() {
    }
    
    @objc private func onRegisterButtonTapped() {
    }
}
