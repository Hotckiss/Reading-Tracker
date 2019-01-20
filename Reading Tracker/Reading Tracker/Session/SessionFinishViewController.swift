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
    var onCompleted: ((UploadSessionModel) -> Void)?
    private var model: SessionFinishModel
    private var spinner: SpinnerView?
    private var commentTextField: RTTextField!
    private let commentTextFieldDelegate = FinishTextFieldDelegate()
    private var moodPollView: PollView!
    private var placePollView: PollView!
    private var startPageTextField: PageTextField?
    private var finishPageTextField: PageTextField?
    
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
        setupSpinner()
    }
    
    private func setupSubviews() {
        let navBar = NavigationBar(frame: .zero)
        navBar.configure(model: NavigationBarModel(title: "Оцените чтение",
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
        startPageTextField.setup(value: model.bookInfo.lastReadPage)
        self.startPageTextField = startPageTextField
        
        let finishPageTextField = PageTextField(frame: .zero)
        finishPageTextField.configure(placeholder: "Конечная\nстраница")
        view.addSubview(finishPageTextField)
        finishPageTextField.autoPinEdge(.left, to: .right, of: separatorLabel, withOffset: 20)
        finishPageTextField.autoPinEdge(.top, to: .bottom, of: navBar, withOffset: SizeDependent.instance.convertPadding(40))
        finishPageTextField.autoSetDimensions(to: CGSize(width: 86, height: 92))
        let autoTime = Int(round(Double(model.time) * model.bookInfo.averagePages))
        var autoLastPage = model.bookInfo.lastReadPage + autoTime
        if model.bookInfo.totalPages > 0 {
            autoLastPage = min(model.bookInfo.pagesCount, autoLastPage)
        }
        finishPageTextField.setup(value: autoLastPage)
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
        
        let moodPollView = PollView(frame: .zero, title: "Эмоции от чтения", options:
            [PollViewOption(image: UIImage(named: "very sad"), text: nil),
             PollViewOption(image: UIImage(named: "sad"), text: nil),
             PollViewOption(image: UIImage(named: "neutral"), text: nil),
             PollViewOption(image: UIImage(named: "happy"), text: nil),
             PollViewOption(image: UIImage(named: "very happy"), text: nil)
            ])
        
        view.addSubview(moodPollView)
        moodPollView.autoAlignAxis(toSuperviewAxis: .vertical)
        moodPollView.autoPinEdge(.top, to: .bottom, of: lineView, withOffset: SizeDependent.instance.convertPadding(88))
        self.moodPollView = moodPollView
        
        let placePollView = PollView(frame: .zero, title: "Место чтения", options:
            [PollViewOption(image: UIImage(named: "home"), text: "Дом"),
             PollViewOption(image: UIImage(named: "transport"), text: "Дорога"),
             PollViewOption(image: UIImage(named: "work"), text: "Работа"),
             PollViewOption(image: UIImage(named: "third place"), text: "Другое")
            ])
        view.addSubview(placePollView)
        placePollView.autoAlignAxis(toSuperviewAxis: .vertical)
        placePollView.autoPinEdge(.top, to: .bottom, of: moodPollView, withOffset: SizeDependent.instance.convertPadding(88))
        self.placePollView = placePollView
    }
    
    private func sendResults() {
        guard let start = startPageTextField?.page,
            let finish = finishPageTextField?.page else {
                self.showError(reason: "Пожалуйста, ведите страницы")
                return
        }
        
        guard start <= finish else {
            self.showError(reason: "Первая страница должна быть не более последней")
            return
        }
        
        guard (finish <= model.bookInfo.pagesCount) || (model.bookInfo.pagesCount == 0) else {
            self.showError(reason: "Последняя страница превышает общее число страниц")
            return
        }
        
        model.startPage = start
        model.finishPage = finish
        let mood = Mood(ind: moodPollView.result)
        let place = ReadPlace(ind: placePollView.result)
        let comment = commentTextField.text ?? ""
        
        model.mood = mood
        model.readPlace = place
        model.comment = comment
        
        let bookModel = model.bookInfo
        let time = model.time
        FirestoreManager.DBManager.uploadSession(session: model,
                                                 completion: ({ [weak self] sessionId in
                                                    FirestoreManager
                                                        .DBManager
                                                        .updateBookAfterSession(book: bookModel,
                                                                                firstReadPage: start,
                                                                           lastReadPage: finish,
                                                                           time: time,
                                                                           onCompleted: ({
                                                                            self?.navigationController?.popViewController(animated: true)
                                                                            guard let model = self?.model else {
                                                                                return
                                                                            }
                                                                            
                                                                            let usm = UploadSessionModel(sessionId: sessionId,
                                                                                                         bookId: model.bookInfo.id,
                                                                                                         startPage: model.startPage,
                                                                                                         finishPage: model.finishPage,
                                                                                                         time: model.time,
                                                                                                         startTime: model.startTime,
                                                                                                         finishTime: model.finishTime,
                                                                                                         mood: mood,
                                                                                                         readPlace: place,
                                                                                                         comment: comment)
                                                                            
                                                                            self?.onCompleted?(usm)
                                                                           }),
                                                                           onError: nil)
                                                 }),
                                                 onError: nil)
    }
    
    private func showError(reason: String) {
        let alert = UIAlertController(title: "Ошибка!", message: reason, preferredStyle: .alert)
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
