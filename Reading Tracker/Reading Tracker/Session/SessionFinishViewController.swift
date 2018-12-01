//
//  SessionFinishViewController.swift
//  Reading Tracker
//
//  Created by Andrei Kirilenko on 11/11/2018.
//  Copyright © 2018 Andrei Kirilenko. All rights reserved.
//

import Foundation
import UIKit

public enum Mood: String {
    case sad = "sad"
    case neutral = "neutral"
    case happy = "happy"
    case unknown = "unknown"
    
    init(ind: Int?) {
        if let ind = ind {
            switch ind {
            case 0:
                self = .happy
            case 1:
                self = .neutral
            case 2:
                self = .sad
            default:
                self = .unknown
            }
        } else {
            self = .unknown
        }
    }
    
    init(str: String) {
        switch str {
        case "happy":
            self = .happy
        case "neutral":
            self = .neutral
        case "sad":
            self = .sad
        default:
            self = .unknown
        }
    }
}

public enum ReadPlace: String {
    case home = "home"
    case transport = "transport"
    case work = "work"
    case unknown = "unknown"
    
    init(ind: Int?) {
        if let ind = ind {
            switch ind {
            case 0:
                self = .home
            case 1:
                self = .transport
            case 2:
                self = .work
            default:
                self = .unknown
            }
        } else {
            self = .unknown
        }
    }
    
    init(str: String) {
        switch str {
        case "home":
            self = .home
        case "transport":
            self = .transport
        case "work":
            self = .work
        default:
            self = .unknown
        }
    }
}
    
public struct SessionFinishModel {
    var bookInfo: BookModel
    var startPage: Int
    var finishPage: Int
    var time: Int
    var startTime: Date
    var mood: Mood
    var readPlace: ReadPlace
    var comment: String
    
    public init(bookInfo: BookModel,
                startPage: Int,
                finishPage: Int,
                time: Int,
                startTime: Date,
                mood: Mood = .unknown,
                readPlace: ReadPlace = .unknown,
                comment: String = "") {
        self.bookInfo = bookInfo
        self.startPage = startPage
        self.finishPage = finishPage
        self.time = time
        self.startTime = startTime
        self.mood = mood
        self.readPlace = readPlace
        self.comment = comment
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
                                                    let mood = Mood(ind: strongSelf.moodPollView.result)
                                                    let place = ReadPlace(ind: strongSelf.placePollView.result)
                                                    let comment = strongSelf.commentTextField.text ?? ""
                                                    
                                                    self?.model?.mood = mood
                                                    self?.model?.readPlace = place
                                                    self?.model?.comment = comment
                                                    
                                                    if let model = strongSelf.model {
                                                        FirestoreManager.DBManager.uploadSession(session: model,
                                                                                                 completion: ({
                                                                                                    strongSelf.navigationController?.popViewController(animated: true)
                                                                                                    //TODO reset session VC
                                                                                                 }),
                                                                                                 onError: ({
                                                                                                    //TODO alert, hide spinner
                                                                                                 }))
                                                    } else {
                                                        let alert = UIAlertController(title: "Ошибка!", message: "Сессия не найдена", preferredStyle: .alert)
                                                        alert.addAction(UIAlertAction(title: "Ок", style: .default, handler: nil))
                                                        self?.present(alert, animated: true, completion: nil)
                                                    }
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
    
    private class PollView: UIView {
        var result: Int?
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
