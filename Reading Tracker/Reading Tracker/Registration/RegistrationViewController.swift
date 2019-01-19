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
import FBSDKLoginKit
import TwitterKit

class RegistrationViewController: UIViewController/*, GIDSignInUIDelegate, FBSDKLoginButtonDelegate*/ {
    private let disposeBag = DisposeBag()
    
    private var spinner: SpinnerView?
    private var greetingImage: UIImageView?
    private var loginButton: UIButton?
    private var codeButton: UIButton?
    //private var stackView: UIStackView?
    override func viewDidLoad() {
        super.viewDidLoad()
        //GIDSignIn.sharedInstance().uiDelegate = self
        setupSubviews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = true
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        view.backgroundColor = UIColor(rgb: 0x2f5870)
    }
    
    private func setupSubviews() {
        let navBar = NavigationBar(frame: .zero)
        navBar.configure(model: NavigationBarModel(title: "",
                                                   onBackButtonPressed: ({ [weak self] in
                                                    self?.navigationController?.popViewController(animated: true)
                                                   })))
        navBar.setBackButtonImage(image: UIImage(named: "back"))
        view.addSubview(navBar)
        navBar.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .bottom)
        setupGreeting()
        //setupSignInButtons()
        setupRegisterButton()
        setupLoginButton()
        setupSpinner()
    }
    
    /*private func setupSignInButtons() {
        guard let greetingImage = greetingImage else {
            return
        }
        
        let signInButtonGoogle: GIDSignInButton = GIDSignInButton(forAutoLayout: ())
        //signInButtonGoogle.style = .iconOnly
        
        let signInButtonFB = FBSDKLoginButton()
        signInButtonFB.delegate = self
        
        let signInButtonTWT = TWTRLogInButton(logInCompletion: { session, error in
            if let error = error {
                print("Error in twitter auth: \(error.localizedDescription)")
                return
            }
            guard let session = session else {
                print("Error in twitter auth: session is nil")
                return
            }
            
            let authToken = session.authToken
            let authTokenSecret = session.authTokenSecret
            
            let credential = TwitterAuthProvider.credential(withToken: authToken, secret: authTokenSecret)
            
            OnLiginStuff.tryLogin(credential: credential, completion: ({ [weak self] result in
                self?.navigationController?.popToRootViewController(animated: true)
                //...
            }))
        })
        
        // todo: unlock buttons
        let stackView = UIStackView(arrangedSubviews: [signInButtonGoogle/*, signInButtonFB, signInButtonTWT*/])
        stackView.spacing = 8
        stackView.axis = .vertical
        view.addSubview(stackView)
        
        stackView.autoAlignAxis(toSuperviewAxis: .vertical)
        stackView.autoresizingMask = [.flexibleWidth]
        stackView.autoPinEdge(.top, to: .bottom, of: greetingImage, withOffset: 77)
        
        self.stackView = stackView
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if let error = error {
            print(error.localizedDescription)
            return
        }
        
        let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
        
        OnLiginStuff.tryLogin(credential: credential, completion: ({ [weak self] result in
            self?.navigationController?.popToRootViewController(animated: true)
        }))
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        // log out...
    }*/
    
    private func setupRegisterButton() {
        guard let greetingImage = greetingImage else {
            return
        }
        
        let codeButton = UIButton(forAutoLayout: ())
        
        let buttonTextAttributes = [
            NSAttributedString.Key.foregroundColor : UIColor(rgb: 0x2f5870),
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: 24, weight: .medium)]
            as [NSAttributedString.Key : Any]
        
        codeButton.setAttributedTitle(NSAttributedString(string: "Код участника", attributes: buttonTextAttributes), for: .normal)
        codeButton.backgroundColor = .white
        codeButton.layer.cornerRadius = 32
        codeButton.addTarget(self, action: #selector(onCodeButtonTapped), for: .touchUpInside)
        
        view.addSubview(codeButton)
        codeButton.autoPinEdge(.top, to: .bottom, of: greetingImage, withOffset: 40)
        codeButton.autoSetDimensions(to: CGSize(width: 223, height: 64))
        codeButton.autoAlignAxis(toSuperviewAxis: .vertical)
        
        self.codeButton = codeButton
    }
    
    private func setupGreeting() {
        let greetingImage = UIImageView(forAutoLayout: ())
        greetingImage.image = UIImage(named: "titleImage")
        
        view.addSubview(greetingImage)
        greetingImage.autoSetDimensions(to: CGSize(width: 332, height: 166))
        greetingImage.autoAlignAxis(toSuperviewAxis: .vertical)
        greetingImage.autoPinEdge(toSuperviewEdge: .top, withInset: SizeDependent.instance.convertPadding(70))
        
        self.greetingImage = greetingImage
    }
    
    private func setupLoginButton() {
        guard let codeButton = codeButton else {
            return
        }
        
        let loginButton = UIButton(forAutoLayout: ())
        
        let buttonTextAttributes = [
            NSAttributedString.Key.foregroundColor : UIColor.white,
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: 20, weight: .medium)]
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
        let vc = LoginPasswordRegistrationViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func onCodeButtonTapped() {
        let vc = OfflineCodeSignUpViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func setupSpinner() {
        let spinner = SpinnerView(frame: .zero)
        view.addSubview(spinner)
        
        view.bringSubviewToFront(spinner)
        spinner.autoPinEdgesToSuperviewEdges()
        self.spinner = spinner
    }
}
