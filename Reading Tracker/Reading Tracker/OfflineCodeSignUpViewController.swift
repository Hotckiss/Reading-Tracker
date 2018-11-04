//
//  OfflineCodeSignUpViewController.swift
//  Reading Tracker
//
//  Created by Andrei Kirilenko on 04/11/2018.
//  Copyright © 2018 Andrei Kirilenko. All rights reserved.
//

import UIKit
import PureLayout
import RxSwift
import Firebase

class OfflineCodeSignUpViewController: UIViewController {
    private var spinner: UIActivityIndicatorView?
    private var codeTextField: RTTextField?
    private let codeTextFieldDelegate = FinishTextFieldDelegate()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubviews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = true
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        view.backgroundColor = .white
    }
    
    private func setupSubviews() {
        let navBar = NavigationBar(frame: .zero)
        navBar.configure(model: NavigationBarModel(title: "Активация кода участника",
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
        
        let codeTextField = RTTextField(padding: .zero)
        codeTextField.attributedPlaceholder = NSAttributedString(string: "Код участника", attributes: placeholderTextAttributes)
        codeTextField.backgroundColor = .clear
        codeTextField.autocorrectionType = .no
        codeTextField.keyboardType = .decimalPad
        codeTextField.delegate = codeTextFieldDelegate
        codeTextField.returnKeyType = .done
        
        view.addSubview(codeTextField)
        codeTextField.autoAlignAxis(toSuperviewAxis: .vertical)
        codeTextField.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 210, left: 16, bottom: 0, right: 0), excludingEdge: .bottom)
        
        self.codeTextField = codeTextField
        
        let lineView = UIView(frame: .zero)
        lineView.backgroundColor = UIColor(rgb: 0x2f5870)
        
        view.addSubview(lineView)
        lineView.autoPinEdge(.top, to: .bottom, of: codeTextField, withOffset: 8)
        lineView.autoPinEdge(toSuperviewEdge: .left, withInset: 16)
        lineView.autoPinEdge(toSuperviewEdge: .right, withInset: 16)
        lineView.autoSetDimension(.height, toSize: 1)
        
        let activateButton = UIButton(frame: .zero)
        
        let buttonTextAttributes = [
            NSAttributedString.Key.foregroundColor : UIColor.white,
            NSAttributedString.Key.font : UIFont(name: "Avenir-Medium", size: 20.0)!]
            as [NSAttributedString.Key : Any]
        
        activateButton.setAttributedTitle(NSAttributedString(string: "Активировать код", attributes: buttonTextAttributes), for: .normal)
        activateButton.backgroundColor = UIColor(rgb: 0x2f5870)
        activateButton.layer.cornerRadius = 32
        activateButton.addTarget(self, action: #selector(onActivateButtonTapped), for: .touchUpInside)
        
        view.addSubview(activateButton)
        activateButton.autoPinEdge(toSuperviewEdge: .bottom, withInset: 100)
        activateButton.autoSetDimensions(to: CGSize(width: 274, height: 64))
        activateButton.autoAlignAxis(toSuperviewAxis: .vertical)
        
    }
    
    @objc private func onActivateButtonTapped() {
        //todo: activation
        let code = codeTextField?.text ?? ""
        print("Code: \(code)")
        navigationController?.popViewController(animated: true)
    }
    
    private class FinishTextFieldDelegate: NSObject, UITextFieldDelegate {
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            textField.resignFirstResponder()
            return true
        }
    }
}

