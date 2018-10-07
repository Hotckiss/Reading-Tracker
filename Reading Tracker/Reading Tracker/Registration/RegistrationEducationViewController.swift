//
//  RegistrationEducationViewController.swift
//  Reading Tracker
//
//  Created by Andrei Kirilenko on 07.10.2018.
//  Copyright © 2018 Andrei Kirilenko. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class RegistrationEducationViewController: UIViewController {
    private var educationTextField: RTTextField?
    private var majorTextField: RTTextField?
    private var occupationTextField: RTTextField?
    private var finishButton: UIButton?
    private var finishButtonBottomConstraint: NSLayoutConstraint?
    
    private let educationTextFieldDelegate = IntermediateTextFieldDelegate()
    private let majorTextFieldDelegate = IntermediateTextFieldDelegate()
    private let occupationTextFieldDelegate = FinishTextFieldDelegate()
    
    deinit {
        NotificationCenter.default.removeObserver(UIResponder.keyboardWillShowNotification)
        NotificationCenter.default.removeObserver(UIResponder.keyboardWillHideNotification)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .orange
        setupSubviews()
        setupFinishButton()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func setupSubviews() {
        let navBar = NavigationBar(frame: .zero)
        navBar.configure(model: NavigationBarModel(title: "Образование",
                                                   backButtonText: "Назад",
                                                   frontButtonText: "Справка",
                                                   onBackButtonPressed: ({ [weak self] in
                                                    self?.navigationController?.popViewController(animated: true)
                                                   }),                                        onFrontButtonPressed: ({
                                                    let alert = UIAlertController(title: "Справка", message: "Введите информацию о себе", preferredStyle: .alert)
                                                    alert.addAction(UIAlertAction(title: "Ок", style: .default, handler: nil))
                                                    self.present(alert, animated: true, completion: nil)
                                                   })))
        let educationTextField = RTTextField()
        educationTextField.placeholder = "Образование"
        educationTextField.backgroundColor = UIColor(rgb: 0xad5205).withAlphaComponent(0.3)
        educationTextField.autocorrectionType = .no
        educationTextField.delegate = educationTextFieldDelegate
        educationTextField.returnKeyType = .continue
        educationTextField.text = RegistrationDraft.registrationDraftInstance.getEducation()
        
        let majorTextField = RTTextField()
        majorTextField.placeholder = "Направление образования"
        majorTextField.backgroundColor = UIColor(rgb: 0xad5205).withAlphaComponent(0.3)
        majorTextField.autocorrectionType = .no
        majorTextField.delegate = majorTextFieldDelegate
        majorTextField.returnKeyType = .continue
        majorTextField.text = RegistrationDraft.registrationDraftInstance.getMajor()
        educationTextFieldDelegate.nextField = majorTextField
        
        let occupationTextField = RTTextField()
        occupationTextField.placeholder = "Род деятельности"
        occupationTextField.backgroundColor = UIColor(rgb: 0xad5205).withAlphaComponent(0.3)
        occupationTextField.autocorrectionType = .no
        occupationTextField.delegate = occupationTextFieldDelegate
        occupationTextField.returnKeyType = .done
        occupationTextField.text = RegistrationDraft.registrationDraftInstance.getOccupation()
        majorTextFieldDelegate.nextField = occupationTextField
        
        view.addSubview(navBar)
        view.addSubview(educationTextField)
        view.addSubview(majorTextField)
        view.addSubview(occupationTextField)
        
        navBar.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: UIApplication.shared.statusBarFrame.height, left: 0, bottom: 0, right: 0), excludingEdge: .bottom)
        
        educationTextField.autoPinEdge(toSuperviewEdge: .left)
        educationTextField.autoPinEdge(toSuperviewEdge: .right)
        educationTextField.autoPinEdge(.top, to: .bottom, of: navBar, withOffset: 24)
        educationTextField.autoSetDimension(.height, toSize: 48)
        
        majorTextField.autoPinEdge(toSuperviewEdge: .left)
        majorTextField.autoPinEdge(toSuperviewEdge: .right)
        majorTextField.autoPinEdge(.top, to: .bottom, of: educationTextField, withOffset: 24)
        majorTextField.autoSetDimension(.height, toSize: 48)
        
        occupationTextField.autoPinEdge(toSuperviewEdge: .left)
        occupationTextField.autoPinEdge(toSuperviewEdge: .right)
        occupationTextField.autoPinEdge(.top, to: .bottom, of: majorTextField, withOffset: 24)
        occupationTextField.autoSetDimension(.height, toSize: 48)
        
        self.educationTextField = educationTextField
        self.majorTextField = majorTextField
        self.occupationTextField = occupationTextField
        
        educationTextField.addTarget(self, action: #selector(educationTextFieldDidChange(_:)), for: .editingChanged)
        majorTextField.addTarget(self, action: #selector(majorTextFieldDidChange(_:)), for: .editingChanged)
        occupationTextField.addTarget(self, action: #selector(occupationTextFieldDidChange(_:)), for: .editingChanged)
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
    
    @objc func educationTextFieldDidChange(_ textField: UITextField) {
        RegistrationDraft.registrationDraftInstance.setEducation(education: textField.text ?? "")
        updateFinishButton()
    }
    
    @objc func majorTextFieldDidChange(_ textField: UITextField) {
        RegistrationDraft.registrationDraftInstance.setMajor(major: textField.text ?? "")
    }
    
    @objc func occupationTextFieldDidChange(_ textField: UITextField) {
        RegistrationDraft.registrationDraftInstance.setOccupation(occupation: textField.text ?? "")
        updateFinishButton()
    }
    
    private func updateFinishButton() {
        guard let occupation = occupationTextField?.text,
              let education = educationTextField?.text else {
            finishButton?.layer.borderWidth = 2
            finishButton?.backgroundColor = .clear
            return
        }
        
        if !occupation.isEmpty && !education.isEmpty {
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
