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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSubviews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = true
        view.backgroundColor = .white
    }
    
    private func setupSubviews() {
        setupGreeting()
        
        let loginLabel = UILabel(forAutoLayout: ())
        loginLabel.textColor = .blue
        loginLabel.text = "Логин"
        
        let loginTextField = RTTextField()
        loginTextField.placeholder = "логин"
        loginTextField.layer.borderWidth = 1
        loginTextField.layer.cornerRadius = 4
        loginTextField.layer.borderColor = UIColor.darkGray.cgColor
        loginTextField.backgroundColor = UIColor(rgb: 0xe5e5e5)
        loginTextField.autocorrectionType = .no
        
        let loginStackView = UIStackView(arrangedSubviews: [loginLabel, loginTextField])
        loginStackView.spacing = 8
        loginStackView.axis = .horizontal
        
        let passwordLabel = UILabel(forAutoLayout: ())
        passwordLabel.textColor = .blue
        passwordLabel.text = "Пароль"
        
        let passwordTextField = RTTextField()
        passwordTextField.placeholder = "пароль"
        passwordTextField.layer.borderWidth = 1
        passwordTextField.layer.cornerRadius = 4
        passwordTextField.layer.borderColor = UIColor.darkGray.cgColor
        passwordTextField.backgroundColor = UIColor(rgb: 0xe5e5e5)
        passwordTextField.autocorrectionType = .no
        passwordTextField.isSecureTextEntry = true
        
        let passwordStackView = UIStackView(arrangedSubviews: [passwordLabel, passwordTextField])
        passwordStackView.spacing = 8
        passwordStackView.axis = .horizontal
        
        let authorizationStackView = UIStackView(arrangedSubviews: [loginStackView, passwordStackView])
        authorizationStackView.spacing = 16
        authorizationStackView.axis = .vertical
        authorizationStackView.alpha = 0
        view.addSubview(authorizationStackView)
        
        loginTextField.autoSetDimensions(to: CGSize(width: 196, height: 32))
        passwordTextField.autoSetDimensions(to: CGSize(width: 196, height: 32))
        authorizationStackView.autoCenterInSuperview()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: ({
            UIView.animate(withDuration: 0.5, animations: ({
                authorizationStackView.alpha = 1
            }))
        }))
        
        let loginButton = UIButton(forAutoLayout: ())
        
        let buttonTextAttributes = [
            NSAttributedString.Key.foregroundColor : UIColor(rgb: 0x1f1f1f),
            NSAttributedString.Key.font : UIFont(name: "AvenirNext-Bold", size: 24.0)!]
            as [NSAttributedString.Key : Any]
        
        loginButton.setAttributedTitle(NSAttributedString(string: "Войти", attributes: buttonTextAttributes), for: .normal)
        loginButton.backgroundColor = UIColor(rgb: 0x75ff75)
        loginButton.layer.borderColor = UIColor.blue.cgColor
        loginButton.layer.cornerRadius = 8
        loginButton.layer.borderWidth = 1
        view.addSubview(loginButton)
        loginButton.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 0, left: 16, bottom: 16, right: 16), excludingEdge: .top)
        loginButton.autoSetDimension(.height, toSize: 56)
    }
    
    private func setupGreeting() {
        let greetingLabel = UILabel(forAutoLayout: ())
        greetingLabel.numberOfLines = 0
        greetingLabel.textAlignment = .center
        let greetingText = "Welcome to\nReading Tracker!"
        
        let textAttributes = [
            NSAttributedString.Key.foregroundColor : UIColor(rgb: 0x1f1f1f),
            NSAttributedString.Key.font : UIFont(name: "Chalkduster", size: 24.0)!]
            as [NSAttributedString.Key : Any]
        
        greetingLabel.attributedText = NSAttributedString(string: greetingText, attributes: textAttributes)
        
        
        view.addSubview(greetingLabel)
        greetingLabel.autoAlignAxis(toSuperviewAxis: .vertical)
        greetingLabel.autoPinEdge(toSuperviewEdge: .top, withInset: 128)
    }
}
