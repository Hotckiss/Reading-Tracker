//
//  RegistrationAboutSelfViewController.swift
//  Reading Tracker
//
//  Created by Andrei Kirilenko on 07.10.2018.
//  Copyright © 2018 Andrei Kirilenko. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class RegistrationAboutSelfViewController: UIViewController {
    private var firstNameTextField: RTTextField?
    private var lastNameTextField: RTTextField?
    private var sexTextField: RTTextField?
    private var finishButton: UIButton?
    private var finishButtonBottomConstraint: NSLayoutConstraint?
    
    private let firstNameTextFieldDelegate = IntermediateTextFieldDelegate()
    private let lastNameTextFieldDelegate = IntermediateTextFieldDelegate()
    private let sexTextFieldDelegate = FinishTextFieldDelegate()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .orange
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
        navBar.configure(model: NavigationBarModel(title: "О себе",
                                                   backButtonText: "Назад",
                                                   frontButtonText: "Справка",
                                                   onBackButtonPressed: ({ [weak self] in
                                                    self?.navigationController?.popViewController(animated: true)
                                                   }),                                        onFrontButtonPressed: ({
                                                    let alert = UIAlertController(title: "Справка", message: "Введите информацию о себе", preferredStyle: .alert)
                                                    alert.addAction(UIAlertAction(title: "Ок", style: .default, handler: nil))
                                                    self.present(alert, animated: true, completion: nil)
                                                   })))
        
        let firstNameTextField = RTTextField()
        firstNameTextField.placeholder = "имя"
        firstNameTextField.backgroundColor = UIColor(rgb: 0xad5205).withAlphaComponent(0.3)
        firstNameTextField.autocorrectionType = .no
        firstNameTextField.delegate = firstNameTextFieldDelegate
        firstNameTextField.returnKeyType = .continue
        firstNameTextField.text = RegistrationDraft.registrationDraftInstance.getFirstName()
        
        let lastNameTextField = RTTextField()
        lastNameTextField.placeholder = "фамилия"
        lastNameTextField.backgroundColor = UIColor(rgb: 0xad5205).withAlphaComponent(0.3)
        lastNameTextField.autocorrectionType = .no
        lastNameTextField.delegate = lastNameTextFieldDelegate
        lastNameTextField.returnKeyType = .continue
        lastNameTextField.text = RegistrationDraft.registrationDraftInstance.getLastName()
        firstNameTextFieldDelegate.nextField = lastNameTextField
        
        let sexTextField = RTTextField()
        sexTextField.placeholder = "пол"
        sexTextField.backgroundColor = UIColor(rgb: 0xad5205).withAlphaComponent(0.3)
        sexTextField.autocorrectionType = .no
        sexTextField.delegate = sexTextFieldDelegate
        sexTextField.returnKeyType = .done
        lastNameTextFieldDelegate.nextField = sexTextField
        
        view.addSubview(navBar)
        view.addSubview(firstNameTextField)
        view.addSubview(lastNameTextField)
        view.addSubview(sexTextField)
        
        navBar.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: UIApplication.shared.statusBarFrame.height, left: 0, bottom: 0, right: 0), excludingEdge: .bottom)
        
        firstNameTextField.autoPinEdge(toSuperviewEdge: .left)
        firstNameTextField.autoPinEdge(toSuperviewEdge: .right)
        firstNameTextField.autoPinEdge(.top, to: .bottom, of: navBar, withOffset: 24)
        firstNameTextField.autoSetDimension(.height, toSize: 48)
        
        lastNameTextField.autoPinEdge(toSuperviewEdge: .left)
        lastNameTextField.autoPinEdge(toSuperviewEdge: .right)
        lastNameTextField.autoPinEdge(.top, to: .bottom, of: firstNameTextField, withOffset: 24)
        lastNameTextField.autoSetDimension(.height, toSize: 48)
        
        sexTextField.autoPinEdge(toSuperviewEdge: .left)
        sexTextField.autoPinEdge(toSuperviewEdge: .right)
        sexTextField.autoPinEdge(.top, to: .bottom, of: lastNameTextField, withOffset: 24)
        sexTextField.autoSetDimension(.height, toSize: 48)
        
        self.firstNameTextField = firstNameTextField
        self.lastNameTextField = lastNameTextField
        self.sexTextField = sexTextField
        
        firstNameTextField.addTarget(self, action: #selector(firstNameTextFieldDidChange(_:)), for: .editingChanged)
        lastNameTextField.addTarget(self, action: #selector(lastNameTextFieldDidChange(_:)), for: .editingChanged)
        sexTextField.addTarget(self, action: #selector(sexTextFieldDidChange(_:)), for: .editingChanged)
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
        
    }
    
    @objc func firstNameTextFieldDidChange(_ textField: UITextField) {
        RegistrationDraft.registrationDraftInstance.setFirstName(firstName: textField.text ?? "")
        updateFinishButton()
    }
    
    @objc func lastNameTextFieldDidChange(_ textField: UITextField) {
        RegistrationDraft.registrationDraftInstance.setLastName(lastName: textField.text ?? "")
        updateFinishButton()
    }
    
    @objc func sexTextFieldDidChange(_ textField: UITextField) {
        updateFinishButton()
    }
    
    private func updateFinishButton() {
        guard let firstName = firstNameTextField?.text else {
            finishButton?.layer.borderWidth = 2
            finishButton?.backgroundColor = .clear
            return
        }
        
        if !firstName.isEmpty {
            finishButton?.layer.borderWidth = 0
            finishButton?.backgroundColor = UIColor(rgb: 0x75ff75)
        } else {
            finishButton?.layer.borderWidth = 2
            finishButton?.backgroundColor = .clear
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
