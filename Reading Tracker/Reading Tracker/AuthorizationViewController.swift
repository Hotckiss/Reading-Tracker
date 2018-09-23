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
    
    private func setupSubviews() {
        let loginLabel = UILabel(forAutoLayout: ())
        loginLabel.textColor = .blue
        loginLabel.text = "Логин"
        
        let loginTextField = UITextField(frame: .zero)
        loginTextField.placeholder = "логин"
        loginTextField.layer.borderWidth = 1
        loginTextField.layer.cornerRadius = 4
        loginTextField.layer.borderColor = UIColor.darkGray.cgColor
        loginTextField.backgroundColor = .lightGray
        loginTextField.autocorrectionType = .no
        
        let loginStackView = UIStackView(arrangedSubviews: [loginLabel, loginTextField])
        loginStackView.spacing = 8
        loginStackView.axis = .horizontal
        
        let passwordLabel = UILabel(frame: .zero)
        passwordLabel.textColor = .blue
        passwordLabel.text = "Пароль"
        
        let passwordTextField = UITextField(frame: .zero)
        passwordTextField.placeholder = "пароль"
        passwordTextField.layer.borderWidth = 1
        passwordTextField.layer.cornerRadius = 4
        passwordTextField.layer.borderColor = UIColor.darkGray.cgColor
        passwordTextField.backgroundColor = .lightGray
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
            UIView.animate(withDuration: 0.7, animations: ({
                authorizationStackView.alpha = 1
            }))
        }))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationItem.hidesBackButton = true
        title = "Вход"
        view.backgroundColor = .white
    }
    
}
