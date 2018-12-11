//
//  SessionFinishViewController.swift
//  Reading Tracker
//
//  Created by Andrei Kirilenko on 11/11/2018.
//  Copyright © 2018 Andrei Kirilenko. All rights reserved.
//

import Foundation
import UIKit

class SessionFinishViewController: UIViewController {
    var model: SessionFinishModel
    private var spinner: UIActivityIndicatorView?
    private var commentTextField: RTTextField!
    private let commentTextFieldDelegate = FinishTextFieldDelegate()
    private var moodPollView: PollView!
    private var placePollView: PollView!
    
    init(model: SessionFinishModel) {
        self.model = model
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
        navBar.configure(model: NavigationBarModel(title: "Оцените чтение",
                                                   backButtonText: "Назад",
                                                   frontButtonText: "Готово",
                                                   onBackButtonPressed: ({ [weak self] in
                                                    self?.navigationController?.popViewController(animated: true)
                                                   }),
                                                   onFrontButtonPressed: ({ [weak self] in
                                                    self?.sendResults()
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
        
        let moodPollView = PollView(frame: .zero, title: "Эмоции от чтения", options: [UIImage(named: "happy"), UIImage(named: "neutral"), UIImage(named: "sad")])
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
    
    private func sendResults() {
        let mood = Mood(ind: moodPollView.result)
        let place = ReadPlace(ind: placePollView.result)
        let comment = commentTextField.text ?? ""
        
        model.mood = mood
        model.readPlace = place
        model.comment = comment
        
        FirestoreManager.DBManager.uploadSession(session: model,
                                                 completion: ({ [weak self] in
                                                    self?.navigationController?.popViewController(animated: true)
                                                    //TODO reset session VC
                                                 }),
                                                 onError: ({
                                                    //TODO alert, hide spinner
                                                 }))
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
}
