//
//  RegistrationFavoritesViewController.swift
//  Reading Tracker
//
//  Created by Andrei Kirilenko on 07.10.2018.
//  Copyright © 2018 Andrei Kirilenko. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class RegistrationFavoritesViewController: UIViewController {
    var interactor: RegistrationInteractor?
    
    private var favoriteBooksTextField: RTTextField?
    private var favoriteAuthorsTextField: RTTextField?
    private var favoriteFormatTextField: RTTextField?
    private var spinner: UIActivityIndicatorView?
    private var finishButton: UIButton?
    private var finishButtonBottomConstraint: NSLayoutConstraint?
    
    private let favoriteBooksTextFieldDelegate = IntermediateTextFieldDelegate()
    private let favoriteAuthorsTextFieldDelegate = IntermediateTextFieldDelegate()
    private let favoriteFormatTextFieldDelegate = FinishTextFieldDelegate()
    
    deinit {
        NotificationCenter.default.removeObserver(UIResponder.keyboardWillShowNotification)
        NotificationCenter.default.removeObserver(UIResponder.keyboardWillHideNotification)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(rgb: 0x232f6d)
        setupSubviews()
        setupFinishButton()
        let spinner = UIActivityIndicatorView()
        
        view.addSubview(spinner)
        
        spinner.autoCenterInSuperview()
        spinner.backgroundColor = UIColor(rgb: 0xad5205).withAlphaComponent(0.7)
        spinner.layer.cornerRadius = 8
        spinner.autoSetDimensions(to: CGSize(width: 64, height: 64))
        self.spinner = spinner
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func setupSubviews() {
        let navBar = NavigationBar(frame: .zero)
        navBar.configure(model: NavigationBarModel(title: "Предпочтения",
                                                   backButtonText: "Назад",
                                                   frontButtonText: "Сбросить",
                                                   onBackButtonPressed: ({ [weak self] in
                                                    self?.navigationController?.popViewController(animated: true)
                                                   }),                                        onFrontButtonPressed: ({
                                                    let alert = UIAlertController(title: "Сбросить", message: "Очистить поля?", preferredStyle: .alert)
                                                    alert.addAction(UIAlertAction(title: "Отмена", style: .default, handler: nil))
                                                    alert.addAction(UIAlertAction(title: "Да", style: .destructive, handler: ({ _ in
                                                        RegistrationDraft.registrationDraftInstance.setFavoriteBooks(books: "")
                                                        RegistrationDraft.registrationDraftInstance.setFavoriteAuthors(authors: "")
                                                        RegistrationDraft.registrationDraftInstance.setFavoriteFormat(format: "")
                                                        self.favoriteBooksTextField?.text = ""
                                                        self.favoriteAuthorsTextField?.text = ""
                                                        self.favoriteFormatTextField?.text = ""
                                                        self.updateFinishButton()
                                                    })))
                                                    self.present(alert, animated: true, completion: nil)
                                                   })))
        let favoriteBooksTextField = RTTextField()
        favoriteBooksTextField.placeholder = "Любимые книги"
        favoriteBooksTextField.backgroundColor = UIColor(rgb: 0xad5205).withAlphaComponent(0.3)
        favoriteBooksTextField.autocorrectionType = .no
        favoriteBooksTextField.delegate = favoriteBooksTextFieldDelegate
        favoriteBooksTextField.returnKeyType = .continue
        favoriteBooksTextField.text = RegistrationDraft.registrationDraftInstance.getFavoriteBooks()
        
        let favoriteAuthorsTextField = RTTextField()
        favoriteAuthorsTextField.placeholder = "Любимые авторы"
        favoriteAuthorsTextField.backgroundColor = UIColor(rgb: 0xad5205).withAlphaComponent(0.3)
        favoriteAuthorsTextField.autocorrectionType = .no
        favoriteAuthorsTextField.delegate = favoriteAuthorsTextFieldDelegate
        favoriteAuthorsTextField.returnKeyType = .continue
        favoriteAuthorsTextField.text = RegistrationDraft.registrationDraftInstance.getFavoriteAuthors()
        favoriteBooksTextFieldDelegate.nextField = favoriteAuthorsTextField
        
        let favoriteFormatTextField = RTTextField()
        favoriteFormatTextField.placeholder = "Любимый формат книги"
        favoriteFormatTextField.backgroundColor = UIColor(rgb: 0xad5205).withAlphaComponent(0.3)
        favoriteFormatTextField.autocorrectionType = .no
        favoriteFormatTextField.delegate = favoriteFormatTextFieldDelegate
        favoriteFormatTextField.returnKeyType = .done
        favoriteFormatTextField.text = RegistrationDraft.registrationDraftInstance.getFavoriteFormat()
        favoriteAuthorsTextFieldDelegate.nextField = favoriteFormatTextField
        
        view.addSubview(navBar)
        view.addSubview(favoriteBooksTextField)
        view.addSubview(favoriteAuthorsTextField)
        view.addSubview(favoriteFormatTextField)
        
        navBar.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: UIApplication.shared.statusBarFrame.height, left: 0, bottom: 0, right: 0), excludingEdge: .bottom)
        
        favoriteBooksTextField.autoPinEdge(toSuperviewEdge: .left)
        favoriteBooksTextField.autoPinEdge(toSuperviewEdge: .right)
        favoriteBooksTextField.autoPinEdge(.top, to: .bottom, of: navBar, withOffset: 24)
        favoriteBooksTextField.autoSetDimension(.height, toSize: 48)
        
        favoriteAuthorsTextField.autoPinEdge(toSuperviewEdge: .left)
        favoriteAuthorsTextField.autoPinEdge(toSuperviewEdge: .right)
        favoriteAuthorsTextField.autoPinEdge(.top, to: .bottom, of: favoriteBooksTextField, withOffset: 24)
        favoriteAuthorsTextField.autoSetDimension(.height, toSize: 48)
        
        favoriteFormatTextField.autoPinEdge(toSuperviewEdge: .left)
        favoriteFormatTextField.autoPinEdge(toSuperviewEdge: .right)
        favoriteFormatTextField.autoPinEdge(.top, to: .bottom, of: favoriteAuthorsTextField, withOffset: 24)
        favoriteFormatTextField.autoSetDimension(.height, toSize: 48)
        
        self.favoriteBooksTextField = favoriteBooksTextField
        self.favoriteAuthorsTextField = favoriteAuthorsTextField
        self.favoriteFormatTextField = favoriteFormatTextField
        
        favoriteBooksTextField.addTarget(self, action: #selector(favoriteBooksTextFieldDidChange(_:)), for: .editingChanged)
        favoriteAuthorsTextField.addTarget(self, action: #selector(favoriteAuthorsTextFieldDidChange(_:)), for: .editingChanged)
        favoriteFormatTextField.addTarget(self, action: #selector(favoriteFormatTextFieldDidChange(_:)), for: .editingChanged)
    }
    
    private func setupFinishButton() {
        let finishButton = UIButton(forAutoLayout: ())
        
        let buttonTextAttributes = [
            NSAttributedString.Key.foregroundColor : UIColor(rgb: 0x1f1f1f),
            NSAttributedString.Key.font : UIFont(name: "AvenirNext-Bold", size: 27.0)!]
            as [NSAttributedString.Key : Any]
        
        finishButton.setAttributedTitle(NSAttributedString(string: "Завершить", attributes: buttonTextAttributes), for: .normal)
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
        spinner?.startAnimating()
        let login = RegistrationDraft.registrationDraftInstance.getLogin()
        let password = RegistrationDraft.registrationDraftInstance.getLogin()
        
        let firstName = RegistrationDraft.registrationDraftInstance.getFirstName()
        let lastName = RegistrationDraft.registrationDraftInstance.getLastName()
        let sex = RegistrationDraft.registrationDraftInstance.getSex()
        
        let education = RegistrationDraft.registrationDraftInstance.getEducation()
        let major = RegistrationDraft.registrationDraftInstance.getMajor()
        let occupation = RegistrationDraft.registrationDraftInstance.getOccupation()
        
        let favoriteBooks = RegistrationDraft.registrationDraftInstance.getFavoriteBooks()
        let favoriteAuthors = RegistrationDraft.registrationDraftInstance.getFavoriteAuthors()
        let favoriteFormat  = RegistrationDraft.registrationDraftInstance.getFavoriteFormat()
        
        Auth.auth().createUser(withEmail: login, password: password) { (authResult, errorRaw) in
            let errorClosure = { (text: String) in
                let alert = UIAlertController(title: "Ошибка!", message: text, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ок", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            
            self.spinner?.stopAnimating()
            if let error = errorRaw {
                errorClosure(error.localizedDescription)
                return
            }
            
            let user = UserModel(firstName: firstName,
                                 lastName: lastName,
                                 birthDate: "",
                                 gender: sex,
                                 degree: education,
                                 major: major,
                                 occupation: occupation,
                                 favoriteBooks: favoriteBooks,
                                 favoriteAuthors: favoriteAuthors,
                                 favoriteFormat: favoriteFormat)
            FirestoreManager.DBManager.registerUser(user: user)
            if let user = authResult {
                self.interactor?.onRegistered(user)
                self.navigationController?.popToRootViewController(animated: false)
            }
        }
    }
    
    @objc func favoriteBooksTextFieldDidChange(_ textField: UITextField) {
        RegistrationDraft.registrationDraftInstance.setFavoriteBooks(books: textField.text ?? "")
    }
    
    @objc func favoriteAuthorsTextFieldDidChange(_ textField: UITextField) {
        RegistrationDraft.registrationDraftInstance.setFavoriteAuthors(authors: textField.text ?? "")
    }
    
    @objc func favoriteFormatTextFieldDidChange(_ textField: UITextField) {
        RegistrationDraft.registrationDraftInstance.setFavoriteFormat(format: textField.text ?? "")
        updateFinishButton()
    }
    
    private func updateFinishButton() {
        guard let favoriteFormat = favoriteFormatTextField?.text else {
                finishButton?.layer.borderWidth = 2
                finishButton?.backgroundColor = .clear
            finishButton?.isUserInteractionEnabled = false
                return
        }
        
        if !favoriteFormat.isEmpty {
            finishButton?.layer.borderWidth = 0
            finishButton?.backgroundColor = UIColor(rgb: 0x75ff75)
            finishButton?.isUserInteractionEnabled = true
        } else {
            finishButton?.layer.borderWidth = 2
            finishButton?.backgroundColor = .clear
            finishButton?.isUserInteractionEnabled = false
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
