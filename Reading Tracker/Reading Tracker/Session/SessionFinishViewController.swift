//
//  SessionFinishViewController.swift
//  Reading Tracker
//
//  Created by Andrei Kirilenko on 11/11/2018.
//  Copyright © 2018 Andrei Kirilenko. All rights reserved.
//

import Foundation
import UIKit

public struct SessionFinishModel {
    var bookInfo: BookModel
    var bookType: BookType
    var startPage: Int
    var finishPage: Int
    var time: Int
    
    public init(bookInfo: BookModel,
                bookType: BookType,
                startPage: Int,
                finishPage: Int,
                time: Int) {
        self.bookInfo = bookInfo
        self.bookType = bookType
        self.startPage = startPage
        self.finishPage = finishPage
        self.time = time
    }
}

class SessionFinishViewController: UIViewController {
    var model: SessionFinishModel?
    private var spinner: UIActivityIndicatorView?
    private var commentTextField: RTTextField!
    private let commentTextFieldDelegate = FinishTextFieldDelegate()
    private var moodPollView: PollView!
    private var placePollView: PollView!
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupSubviews()
    }
    
    private func setupSubviews() {
        let navBar = NavigationBar(frame: .zero)
        navBar.configure(model: NavigationBarModel(title: "Оцените чтение",
                                                   backButtonText: "Назад",
                                                   frontButtonText: "Готово",
                                                   onBackButtonPressed: ({ [weak self] in
                                                    self?.navigationController?.popViewController(animated: true)
                                                   }),
                                                   onFrontButtonPressed: ({ [weak self] in
                                                    guard let strongSelf = self else {
                                                        return
                                                    }
                                                    let mood = strongSelf.moodPollView.result
                                                    let place = strongSelf.placePollView.result
                                                    let comment = strongSelf.commentTextField.text
                                                    //TODO send to db, pop, reset session
                                                   })))
        navBar.backgroundColor = UIColor(rgb: 0x2f5870)
        view.addSubview(navBar)
        navBar.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .bottom)
        
        setupSpinner()
        
        let placeholderTextAttributes = [
            NSAttributedString.Key.foregroundColor : UIColor(rgb: 0x2f5870).withAlphaComponent(0.5),
            NSAttributedString.Key.font : UIFont(name: "Avenir-Light", size: 20.0)!]
            as [NSAttributedString.Key : Any]
        
        let commentTextField = RTTextField(padding: .zero)
        commentTextField.attributedPlaceholder = NSAttributedString(string: "Комментарий к прочитанному", attributes: placeholderTextAttributes)
        commentTextField.backgroundColor = .clear
        commentTextField.autocorrectionType = .no
        commentTextField.delegate = commentTextFieldDelegate
        commentTextField.returnKeyType = .done
        
        view.addSubview(commentTextField)
        commentTextField.autoAlignAxis(toSuperviewAxis: .vertical)
        commentTextField.autoPinEdge(.top, to: .bottom, of: navBar, withOffset: 138)
        commentTextField.autoPinEdge(toSuperviewEdge: .right)
        commentTextField.autoPinEdge(toSuperviewEdge: .left, withInset: 16)
        
        self.commentTextField = commentTextField
        
        let lineView = UIView(frame: .zero)
        lineView.backgroundColor = UIColor(rgb: 0x2f5870)
        
        view.addSubview(lineView)
        lineView.autoPinEdge(.top, to: .bottom, of: commentTextField, withOffset: 8)
        lineView.autoPinEdge(toSuperviewEdge: .left, withInset: 16)
        lineView.autoPinEdge(toSuperviewEdge: .right, withInset: 16)
        lineView.autoSetDimension(.height, toSize: 1)
        
        let moodPollView = PollView(frame: .zero, title: "Эмоции от чтения", options: [UIImage(named: "good"), UIImage(named: "normal"), UIImage(named: "sad")])
        view.addSubview(moodPollView)
        moodPollView.autoAlignAxis(toSuperviewAxis: .vertical)
        moodPollView.autoPinEdge(.top, to: .bottom, of: lineView, withOffset: 88)
        self.moodPollView = moodPollView
        
        let placePollView = PollView(frame: .zero, title: "Место чтения", options: [UIImage(named: "home"), UIImage(named: "transport"), UIImage(named: "work")])
        view.addSubview(placePollView)
        placePollView.autoAlignAxis(toSuperviewAxis: .vertical)
        placePollView.autoPinEdge(.top, to: .bottom, of: moodPollView, withOffset: 88)
        self.placePollView = placePollView
    }
    
    private func setupSpinner() {
        let spinner = UIActivityIndicatorView()
        view.addSubview(spinner)
        
        spinner.autoCenterInSuperview()
        spinner.backgroundColor = UIColor(rgb: 0xad5205).withAlphaComponent(0.7)
        spinner.layer.cornerRadius = 8
        spinner.autoSetDimensions(to: CGSize(width: 64, height: 64))
        self.spinner = spinner
    }
    
    private class FinishTextFieldDelegate: NSObject, UITextFieldDelegate {
        func textFieldDidBeginEditing(_ textField: UITextField) {
            textField.typingAttributes = [
                NSAttributedString.Key.foregroundColor : UIColor(rgb: 0x2f5870),
                NSAttributedString.Key.font : UIFont(name: "Avenir-Medium", size: 20.0)!]
                as [NSAttributedString.Key : Any]
        }
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            textField.resignFirstResponder()
            return true
        }
    }
    
    private class PollView: UIView {
        var result: Int = 0
        private var buttons: [IndexedButton] = []
        
        init(frame: CGRect, title: String, options: [UIImage?]) {
            super.init(frame: frame)
            
            let style = NSMutableParagraphStyle()
            style.alignment = NSTextAlignment.center
            
            let titleTextAttributes = [
                NSAttributedString.Key.foregroundColor : UIColor(rgb: 0x2f5870).withAlphaComponent(0.5),
                NSAttributedString.Key.font : UIFont(name: "Avenir-Light", size: 14.0)!,
                NSAttributedString.Key.paragraphStyle: style]
                as [NSAttributedString.Key : Any]
            
            let titleLabel = UILabel(forAutoLayout: ())
            titleLabel.attributedText = NSAttributedString(string: title, attributes: titleTextAttributes)
            
            addSubview(titleLabel)
            titleLabel.autoPinEdge(toSuperviewEdge: .top)
            titleLabel.autoAlignAxis(toSuperviewAxis: .vertical)
            
            var lastButton: UIButton?
            
            for (index, image) in options.enumerated() {
                let button = IndexedButton(frame: .zero, index: index)
                button.setImage(image?.withRenderingMode(.alwaysTemplate) , for: .normal)
                button.imageView?.tintColor = UIColor(rgb: 0x2f5870).withAlphaComponent(0.5)
                addSubview(button)
                button.autoPinEdge(.top, to: .bottom, of: titleLabel, withOffset: 10)
                button.autoPinEdge(toSuperviewEdge: .bottom)
                button.addTarget(self, action: #selector(onTap(_:)), for: .touchUpInside)
                if let last = lastButton {
                    button.autoPinEdge(.left, to: .right, of: last, withOffset: 25)
                } else {
                    button.autoPinEdge(toSuperviewEdge: .left)
                }
                buttons.append(button)
                lastButton = button
            }
            
            if let last = lastButton {
                last.autoPinEdge(toSuperviewEdge: .right)
            }
        }
        
        @objc private func onTap(_ sender: IndexedButton) {
            for (index, button) in buttons.enumerated() {
                if index == sender.index {
                    button.imageView?.tintColor = UIColor(rgb: 0x2f5870)
                } else {
                    button.imageView?.tintColor = UIColor(rgb: 0x2f5870).withAlphaComponent(0.5)
                }
            }
            
            result = sender.index
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private class IndexedButton: UIButton {
            let index: Int
            init(frame: CGRect, index: Int) {
                self.index = index
                super.init(frame: frame)
            }
            
            required init?(coder aDecoder: NSCoder) {
                fatalError("init(coder:) has not been implemented")
            }
        }
    }
}
