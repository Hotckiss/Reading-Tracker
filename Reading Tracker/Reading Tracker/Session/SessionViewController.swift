//
//  SessionViewController.swift
//  Reading Tracker
//
//  Created by Andrei Kirilenko on 15.10.2018.
//  Copyright © 2018 Andrei Kirilenko. All rights reserved.
//

import Foundation
import UIKit

final class SessionViewController: UIViewController {
    private var spinner: UIActivityIndicatorView?
    private var sessionButton: SessionTimerButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        view.backgroundColor = .white
        setupNavigationBarAndBookCell()
        setupSpinner()
        
        var bottomSpace: CGFloat = 49
        if #available(iOS 11.0, *) {
            bottomSpace += UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
        }
        
        let s = SessionTimerButton(frame: .zero)
        view.addSubview(s)
        
        s.autoPinEdge(toSuperviewEdge: .bottom, withInset: 82 + bottomSpace)
        s.autoAlignAxis(toSuperviewAxis: .vertical)
        s.autoSetDimensions(to: CGSize(width: 230, height: 230))
        s.addTarget(self, action: #selector(onSessionButtonTap), for: .touchUpInside)
        s.buttonState = .start
        sessionButton = s
        
        let handTimeInputButton = UIButton(forAutoLayout: ())
        let handTimeInputButtonTextAttributes = [
            NSAttributedString.Key.foregroundColor : UIColor(rgb: 0x2f5870).withAlphaComponent(0.5),
            NSAttributedString.Key.font : UIFont(name: "Avenir-Light", size: 14.0)!]
            as [NSAttributedString.Key : Any]
        handTimeInputButton.setAttributedTitle(NSAttributedString(string: "Указать время вручную", attributes: handTimeInputButtonTextAttributes), for: [])
        handTimeInputButton.addTarget(self, action: #selector(onHandTimeTap), for:.touchUpInside)
        
        view.addSubview(handTimeInputButton)
        handTimeInputButton.autoAlignAxis(toSuperviewAxis: .vertical)
        handTimeInputButton.autoPinEdge(toSuperviewEdge: .bottom, withInset: bottomSpace + 30)
    }
    
    @objc private func onHandTimeTap() {
        let alert = UIAlertController(title: "Ошибка!", message: "TODO: ручник времени", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ок", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc private func onSessionButtonTap() {
        guard let sessionButton = sessionButton else {
            return
        }
        
        if sessionButton.buttonState == .play {
            sessionButton.buttonState = .pause
        } else {
            sessionButton.buttonState = .play
        }
    }
    private func setupNavigationBarAndBookCell() {
        let navBar = NavigationBar()
        
        navBar.configure(model: NavigationBarModel(title: "Новая запись о чтении",
                                                   backButtonText: "Назад",
                                                   frontButtonText: "Ок",
                                                   onBackButtonPressed: ({
                                                   }),
                                                   onFrontButtonPressed: ({
                                                   })))
        navBar.backgroundColor = UIColor(rgb: 0x2f5870)
        
        view.addSubview(navBar)
        navBar.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .bottom)
        
        let bookCell = BookFilledCell(frame: .zero)
        bookCell.configure(model: BookModel(icbn: "1", title: "Биоцентризм. Как жизнь создает вселенную", author: "Роберт Ланца"))
        
        view.addSubview(bookCell)
        bookCell.autoPinEdge(toSuperviewEdge: .left)
        bookCell.autoPinEdge(toSuperviewEdge: .right)
        bookCell.autoPinEdge(.top, to: .bottom, of: navBar)
        
        let startPageTextField = PageTextField(frame: .zero)
        startPageTextField.configure(placeholder: "Начальная\nстраница")
        
        view.addSubview(startPageTextField)
        startPageTextField.autoPinEdge(toSuperviewEdge: .left, withInset: 16)
        startPageTextField.autoPinEdge(.top, to: .bottom, of: bookCell, withOffset: 20)
        startPageTextField.autoSetDimensions(to: CGSize(width: 86, height: 92))
        
        let finishPageTextField = PageTextField(frame: .zero)
        finishPageTextField.configure(placeholder: "Конечная\nстраница")
        
        view.addSubview(finishPageTextField)
        finishPageTextField.autoPinEdge(toSuperviewEdge: .right, withInset: 16)
        finishPageTextField.autoPinEdge(.top, to: .bottom, of: bookCell, withOffset: 20)
        finishPageTextField.autoSetDimensions(to: CGSize(width: 86, height: 92))
        
    }
    
    private func setupSpinner() {
        let spinner = UIActivityIndicatorView()
        view.addSubview(spinner)
        
        view.bringSubviewToFront(spinner)
        spinner.autoCenterInSuperview()
        spinner.backgroundColor = UIColor(rgb: 0x555555).withAlphaComponent(0.7)
        spinner.layer.cornerRadius = 8
        spinner.autoSetDimensions(to: CGSize(width: 64, height: 64))
        self.spinner = spinner
    }
    
    override func viewWillAppear(_ animated: Bool) {
    }
    
    private class BookFilledCell: UIButton {
        private var model: BookModel = BookModel(title: "", author: "")
        private var titleTextLabel: UILabel?
        private var authorLabel: UILabel?
        private var coverImageView: UIImageView?
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            backgroundColor = .white
            layer.shadowColor = UIColor.black.cgColor
            layer.shadowOpacity = 0.2
            layer.shadowOffset = CGSize(width: 0.0, height: 3.0)
            setupSubviews()
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private func setupSubviews() {
            let titleTextLabel = UILabel(forAutoLayout: ())
            
            let titleTextAttributes = [
                NSAttributedString.Key.foregroundColor : UIColor(rgb: 0x2f5870),
                NSAttributedString.Key.font : UIFont(name: "Avenir-Medium", size: 20.0)!]
                as [NSAttributedString.Key : Any]
            
            titleTextLabel.attributedText = NSAttributedString(string: model.title, attributes: titleTextAttributes)
            titleTextLabel.numberOfLines = 0
            
            let authorLabel = UILabel(forAutoLayout: ())
            
            let authorTextAttributes = [
                NSAttributedString.Key.foregroundColor : UIColor(rgb: 0x2f5870),
                NSAttributedString.Key.font : UIFont(name: "Avenir-Medium", size: 14.0)!]
                as [NSAttributedString.Key : Any]
            
            authorLabel.attributedText = NSAttributedString(string: model.author, attributes: authorTextAttributes)
            authorLabel.numberOfLines = 0
            
            let coverImageView = UIImageView(image: model.image)
            coverImageView.contentMode = .scaleAspectFill
            
            addSubview(titleTextLabel)
            
            titleTextLabel.autoPinEdge(toSuperviewEdge: .left, withInset: 16)
            titleTextLabel.autoPinEdge(toSuperviewEdge: .right, withInset: 16 + 70 + 16)
            titleTextLabel.autoPinEdge(toSuperviewEdge: .top, withInset: 20)
            
            addSubview(authorLabel)
            
            authorLabel.autoPinEdge(toSuperviewEdge: .left, withInset: 16)
            authorLabel.autoPinEdge(toSuperviewEdge: .right, withInset: 16 + 70 + 16)
            authorLabel.autoPinEdge(.top, to: .bottom, of: titleTextLabel, withOffset: 5)
            
            addSubview(coverImageView)
            
            coverImageView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 16), excludingEdge: .left)
            coverImageView.autoSetDimensions(to: CGSize(width: 70, height: 100))
            
            self.titleTextLabel = titleTextLabel
            self.authorLabel = authorLabel
            self.coverImageView = coverImageView
        }
        
        func configure(model: BookModel) {
            self.model = model
            
            let titleTextAttributes = [
                NSAttributedString.Key.foregroundColor : UIColor(rgb: 0x2f5870),
                NSAttributedString.Key.font : UIFont(name: "Avenir-Medium", size: 20.0)!]
                as [NSAttributedString.Key : Any]
            
            let authorTextAttributes = [
                NSAttributedString.Key.foregroundColor : UIColor(rgb: 0x2f5870),
                NSAttributedString.Key.font : UIFont(name: "Avenir-Medium", size: 14.0)!]
                as [NSAttributedString.Key : Any]
            
            titleTextLabel?.attributedText = NSAttributedString(string: model.title, attributes: titleTextAttributes)
            authorLabel?.attributedText = NSAttributedString(string: model.author, attributes: authorTextAttributes)
            coverImageView?.image = model.image
        }
    }
    
    private class PageTextField: UIView, UITextFieldDelegate {
        private var topPlaceholder: UILabel!
        private var emptyPlaceholder: UILabel!
        private var textField: RTTextField!
        private var bottomLine: UIView!
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            let topPlaceholder = UILabel(forAutoLayout: ())
            topPlaceholder.numberOfLines = 0
            let placeholderTextAttributes = [
                NSAttributedString.Key.foregroundColor : UIColor(rgb: 0x2f5870).withAlphaComponent(0.5),
                NSAttributedString.Key.font : UIFont(name: "Avenir-Light", size: 14.0)!]
                as [NSAttributedString.Key : Any]
            topPlaceholder.attributedText = NSAttributedString(string: "Начальная\nстраница", attributes: placeholderTextAttributes)
            
            let emptyPlaceholder = UILabel(forAutoLayout: ())
            emptyPlaceholder.numberOfLines = 0
            emptyPlaceholder.attributedText = NSAttributedString(string: "Начальная\nстраница", attributes: placeholderTextAttributes)
            
            let textField = RTTextField(frame: .zero)
            //textField.def
            textField.defaultTextAttributes = [
                NSAttributedString.Key.foregroundColor : UIColor(rgb: 0x2f5870),
                NSAttributedString.Key.font : UIFont(name: "Avenir-Medium", size: 20.0)!]
                as [NSAttributedString.Key : Any]
            textField.textAlignment = .center
            textField.keyboardType = .decimalPad
            let bottomLine = UIView(forAutoLayout: ())
            bottomLine.backgroundColor = UIColor(rgb: 0x2f5870).withAlphaComponent(0.5)
            
            addSubview(topPlaceholder)
            topPlaceholder.autoAlignAxis(toSuperviewAxis: .vertical)
            topPlaceholder.autoPinEdge(toSuperviewEdge: .top)
            
            addSubview(emptyPlaceholder)
            emptyPlaceholder.autoAlignAxis(toSuperviewAxis: .vertical)
            emptyPlaceholder.autoPinEdge(.top, to: .bottom, of: topPlaceholder, withOffset: 4)
            
            addSubview(textField)
            textField.autoPinEdge(toSuperviewEdge: .left)
            textField.autoPinEdge(toSuperviewEdge: .right)
            textField.autoPinEdge(.top, to: .bottom, of: topPlaceholder, withOffset: 4)
            textField.autoSetDimension(.height, toSize: 38)
            textField.delegate = self
            addSubview(bottomLine)
            bottomLine.autoPinEdge(.top, to: .bottom, of: textField, withOffset: 10)
            bottomLine.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .top)
            bottomLine.autoSetDimension(.height, toSize: 1)
            
            topPlaceholder.isHidden = true
            
            self.topPlaceholder = topPlaceholder
            self.textField = textField
            self.emptyPlaceholder = emptyPlaceholder
            self.bottomLine = bottomLine
        }
        
        func configure(placeholder: String) {
            let placeholderTextAttributes = [
                NSAttributedString.Key.foregroundColor : UIColor(rgb: 0x2f5870).withAlphaComponent(0.5),
                NSAttributedString.Key.font : UIFont(name: "Avenir-Light", size: 14.0)!]
                as [NSAttributedString.Key : Any]
            
            topPlaceholder.attributedText = NSAttributedString(string: placeholder, attributes: placeholderTextAttributes)
            emptyPlaceholder.attributedText = NSAttributedString(string: placeholder, attributes: placeholderTextAttributes)
        }
        
        func textFieldDidEndEditing(_ textField: UITextField) {
            if let text = textField.text,
            text.count > 0 {
                topPlaceholder.isHidden = false
                emptyPlaceholder.isHidden = true
            } else {
                topPlaceholder.isHidden = true
                emptyPlaceholder.isHidden = false
            }
        }
        
        func textFieldDidBeginEditing(_ textField: UITextField) {
            topPlaceholder.isHidden = false
            emptyPlaceholder.isHidden = true
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}
