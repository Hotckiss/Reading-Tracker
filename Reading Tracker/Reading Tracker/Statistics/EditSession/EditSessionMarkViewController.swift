//
//  EditSessionMarkViewController.swift
//  Reading Tracker
//
//  Created by Andrei Kirilenko on 08/01/2019.
//  Copyright © 2019 Andrei Kirilenko. All rights reserved.
//

import Foundation
import UIKit

struct UpdateSessionMarkPackage {
    var startPage: Int
    var finishPage: Int
    var comment: String
    var mood: Mood
    var place: ReadPlace
}

class EditSessionMarkViewController: UIViewController {
    var onUpdate: ((UpdateSessionMarkPackage) -> Void)?
    private var spinner: SpinnerView?
    private var commentTextField: RTTextField!
    private let commentTextFieldDelegate = FinishTextFieldDelegate()
    private var moodPollView: PollView!
    private var placePollView: PollView!
    private var startPageTextField: PageTextField?
    private var finishPageTextField: PageTextField?
    private var package: UpdateSessionMarkPackage?
    private var sessionId = ""
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupSubviews()
    }
    
    private func setupSubviews() {
        let navBar = NavigationBar(frame: .zero)
        navBar.configure(model: NavigationBarModel(title: "Оценка чтения",
                                                   onBackButtonPressed: ({ [weak self] in
                                                    self?.navigationController?.popViewController(animated: true)
                                                   }),
                                                   onFrontButtonPressed: ({ [weak self] in
                                                    self?.sendResults()
                                                   })))
        navBar.backgroundColor = UIColor(rgb: 0x2f5870)
        navBar.setBackButtonImage(image: UIImage(named: "back"))
        navBar.setFrontButtonImage(image: UIImage(named: "tick"))
        view.addSubview(navBar)
        navBar.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .bottom)
        
        let placeholderTextAttributes = [
            NSAttributedString.Key.foregroundColor : UIColor(rgb: 0x2f5870).withAlphaComponent(0.5),
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: 20, weight: .regular)]
            as [NSAttributedString.Key : Any]
        
        let separatorLabel = UILabel(forAutoLayout: ())
        separatorLabel.attributedText = NSAttributedString(string: "\u{2013}", attributes: placeholderTextAttributes)
        view.addSubview(separatorLabel)
        separatorLabel.autoAlignAxis(toSuperviewAxis: .vertical)
        separatorLabel.autoPinEdge(.top, to: .bottom, of: navBar, withOffset: SizeDependent.instance.convertPadding(92))
        
        let startPageTextField = PageTextField(frame: .zero)
        startPageTextField.configure(placeholder: "Начальная\nстраница")
        
        view.addSubview(startPageTextField)
        startPageTextField.autoPinEdge(.right, to: .left, of: separatorLabel, withOffset: -20)
        startPageTextField.autoPinEdge(.top, to: .bottom, of: navBar, withOffset: SizeDependent.instance.convertPadding(40))
        startPageTextField.autoSetDimensions(to: CGSize(width: 86, height: 92))
        self.startPageTextField = startPageTextField
        let finishPageTextField = PageTextField(frame: .zero)
        finishPageTextField.configure(placeholder: "Конечная\nстраница")
        
        view.addSubview(finishPageTextField)
        finishPageTextField.autoPinEdge(.left, to: .right, of: separatorLabel, withOffset: 20)
        finishPageTextField.autoPinEdge(.top, to: .bottom, of: navBar, withOffset: SizeDependent.instance.convertPadding(40))
        finishPageTextField.autoSetDimensions(to: CGSize(width: 86, height: 92))
        self.finishPageTextField = finishPageTextField
        
        let commentTextField = RTTextField(padding: .zero)
        commentTextField.attributedPlaceholder = NSAttributedString(string: "Комментарий к прочитанному", attributes: placeholderTextAttributes)
        commentTextField.backgroundColor = .clear
        commentTextField.autocorrectionType = .no
        commentTextField.delegate = commentTextFieldDelegate
        commentTextField.returnKeyType = .done
        
        view.addSubview(commentTextField)
        commentTextField.autoAlignAxis(toSuperviewAxis: .vertical)
        commentTextField.autoPinEdge(.top, to: .bottom, of: separatorLabel, withOffset: SizeDependent.instance.convertPadding(46))
        commentTextField.autoPinEdge(toSuperviewEdge: .right)
        commentTextField.autoPinEdge(toSuperviewEdge: .left, withInset: 16)
        
        self.commentTextField = commentTextField
        
        let lineView = UIView(frame: .zero)
        lineView.backgroundColor = UIColor(rgb: 0x2f5870)
        
        view.addSubview(lineView)
        lineView.autoPinEdge(.top, to: .bottom, of: commentTextField, withOffset: SizeDependent.instance.convertPadding(8))
        lineView.autoPinEdge(toSuperviewEdge: .left, withInset: 16)
        lineView.autoPinEdge(toSuperviewEdge: .right, withInset: 16)
        lineView.autoSetDimension(.height, toSize: 1)
        
        let moodPollView = PollView(frame: .zero, title: "Эмоции от чтения", options: [UIImage(named: "very sad"), UIImage(named: "sad"), UIImage(named: "neutral"), UIImage(named: "happy"), UIImage(named: "very happy")])
        view.addSubview(moodPollView)
        moodPollView.autoAlignAxis(toSuperviewAxis: .vertical)
        moodPollView.autoPinEdge(.top, to: .bottom, of: lineView, withOffset: SizeDependent.instance.convertPadding(88))
        self.moodPollView = moodPollView
        
        let placePollView = PollView(frame: .zero, title: "Место чтения", options: [UIImage(named: "home"), UIImage(named: "transport"), UIImage(named: "work"), UIImage(named: "third place")])
        view.addSubview(placePollView)
        placePollView.autoAlignAxis(toSuperviewAxis: .vertical)
        placePollView.autoPinEdge(.top, to: .bottom, of: moodPollView, withOffset: SizeDependent.instance.convertPadding(88))
        self.placePollView = placePollView
        
        setupSpinner()
        
        if let usmp = self.package {
            configure(sessionId: self.sessionId, package: usmp)
        }
    }
    
    func configure(sessionId: String, package: UpdateSessionMarkPackage) {
        self.sessionId = sessionId
        self.package = package
        startPageTextField?.setup(value: package.startPage)
        finishPageTextField?.setup(value: package.finishPage)
        commentTextField?.text = package.comment
        if package.mood != .unknown {
            moodPollView?.setup(index: package.mood.index())
        }
        
        if package.place != .unknown {
            placePollView?.setup(index: package.place.index())
        }
    }
    
    private func sendResults() {
        guard !sessionId.isEmpty,
            let start = startPageTextField?.page,
            let finish = finishPageTextField?.page,
            start < finish else {
                self.showError(msg: "Пожалуйста, ведите страницы")
                return
        }
        
        package?.startPage = start
        package?.finishPage = finish
        let mood = Mood(ind: moodPollView.result)
        let place = ReadPlace(ind: placePollView.result)
        let comment = commentTextField.text ?? ""
        
        package?.mood = mood
        package?.place = place
        package?.comment = comment
        
        if let usmp = self.package {
            spinner?.show()
            FirestoreManager.DBManager.updateSessionMark(sessionId: sessionId,
                                                         package: usmp,
                                                         completion: ({ [weak self] in
                                                            self?.spinner?.hide()
                                                            self?.onUpdate?(usmp)
                                                            self?.navigationController?.popViewController(animated: true)
                                                         }),
                                                         onError: ({ [weak self] in
                                                            self?.spinner?.hide()
                                                            self?.showError(msg: "Ошибка загрузки сессии")
                                                         }))
        }
    }
    
    private func showError(msg: String) {
        let alert = UIAlertController(title: "Ошибка!", message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ок", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    private func setupSpinner() {
        let spinner = SpinnerView(frame: .zero)
        view.addSubview(spinner)
        
        view.bringSubviewToFront(spinner)
        spinner.autoPinEdgesToSuperviewEdges()
        self.spinner = spinner
    }
}
