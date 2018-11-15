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
    var onBookAddedInSession: ((BookModel) -> Void)?
    private var spinner: UIActivityIndicatorView?
    private var navBar: NavigationBar?
    private var sessionButton: SessionTimerButton?
    private var bookEmptyCell: BookEmptyCell?
    private var bookCell: BookFilledCell?
    private var startPageTextField: PageTextField?
    private var finishPageTextField: PageTextField?
    private var handTimeInputButton: UIButton?
    private var handTimerView: HandTimerView?
    private var isAutomaticTimeCounterEnabled: Bool = true
    private var bookModel: BookModel?
    
    private var hasBook: Bool = false {
        didSet {
            bookEmptyCell?.isHidden = hasBook
            bookCell?.isHidden = !hasBook
            sessionButton?.isPlaceholder = !hasBook
            startPageTextField?.isUserInteractionEnabled = hasBook
            finishPageTextField?.isUserInteractionEnabled = hasBook
            handTimeInputButton?.isUserInteractionEnabled = hasBook
            handTimeInputButton?.isHidden = !hasBook
            startPageTextField?.disable(disable: !hasBook)
            finishPageTextField?.disable(disable: !hasBook)
            
            if !hasBook {
                finishPageTextField?.isHidden = true
            }
        }
    }
    
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
        
        let sessionButton = SessionTimerButton(frame: .zero)
        view.addSubview(sessionButton)
        
        sessionButton.autoPinEdge(toSuperviewEdge: .bottom, withInset: 82 + bottomSpace)
        sessionButton.autoAlignAxis(toSuperviewAxis: .vertical)
        sessionButton.autoSetDimensions(to: CGSize(width: 230, height: 230))
        sessionButton.addTarget(self, action: #selector(onSessionButtonTap), for: .touchUpInside)
        sessionButton.onStateChanged = { [weak self] state in
            self?.finishPageTextField?.isHidden = (state != .pause)
        }
        sessionButton.buttonState = .start
        
        self.sessionButton = sessionButton
        
        let style = NSMutableParagraphStyle()
        style.alignment = NSTextAlignment.center
        
        let handTimeInputButton = UIButton(forAutoLayout: ())
        let handTimeInputButtonTextAttributes = [
            NSAttributedString.Key.foregroundColor : UIColor(rgb: 0x2f5870),
            NSAttributedString.Key.font : UIFont(name: "Avenir-Light", size: 14.0)!,
            NSAttributedString.Key.paragraphStyle: style]
            as [NSAttributedString.Key : Any]
        handTimeInputButton.setAttributedTitle(NSAttributedString(string: "Указать время вручную", attributes: handTimeInputButtonTextAttributes), for: [])
        handTimeInputButton.addTarget(self, action: #selector(onHandTimeTap), for:.touchUpInside)
        
        view.addSubview(handTimeInputButton)
        handTimeInputButton.autoAlignAxis(toSuperviewAxis: .vertical)
        handTimeInputButton.autoPinEdge(toSuperviewEdge: .bottom, withInset: bottomSpace + 30)
        
        self.handTimeInputButton = handTimeInputButton
        
        let handTimerView = HandTimerView(frame: .zero)
        view.addSubview(handTimerView)
        
        handTimerView.autoPinEdge(toSuperviewEdge: .bottom, withInset: 124 + bottomSpace)
        handTimerView.autoAlignAxis(toSuperviewAxis: .vertical)
        handTimerView.autoSetDimensions(to: CGSize(width: 218, height: 162))
        self.handTimerView = handTimerView
        
        updateTimeInput(isHand: false)
        
        hasBook = (bookModel != nil)
    }
    
    @objc private func onHandTimeTap() {
        isAutomaticTimeCounterEnabled = !isAutomaticTimeCounterEnabled
        updateTimeInput(isHand: !isAutomaticTimeCounterEnabled)
    }
    
    private func updateTimeInput(isHand: Bool) {
        let style = NSMutableParagraphStyle()
        style.alignment = NSTextAlignment.center
        
        let handTimeInputButtonTextAttributes = [
            NSAttributedString.Key.foregroundColor : UIColor(rgb: 0x2f5870),
            NSAttributedString.Key.font : UIFont(name: "Avenir-Light", size: 14.0)!,
            NSAttributedString.Key.paragraphStyle: style]
            as [NSAttributedString.Key : Any]
        handTimeInputButton?.setAttributedTitle(NSAttributedString(string: isHand ? "Вернуться к таймеру" : "Указать время вручную", attributes: handTimeInputButtonTextAttributes), for: [])
        handTimerView?.isHidden = !isHand
        sessionButton?.isHidden = isHand
        
        if isHand {
            finishPageTextField?.isHidden = false
        }
        
        if isHand {
            finishPageTextField?.isHidden = false
        } else {
            finishPageTextField?.isHidden = ((sessionButton?.buttonState ?? .start) != .pause)
        }
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
                                                   backButtonText: "Сброс",
                                                    frontButtonText: "Готово",
                                                    onBackButtonPressed: ({
                                                        //TODO: reset
                                                    }),
                                                    onFrontButtonPressed: ({ [weak self] in
                                                        let showError = {
                                                            let alert = UIAlertController(title: "Ошибка!", message: "Не все поля заполнены", preferredStyle: .alert)
                                                            alert.addAction(UIAlertAction(title: "Ок", style: .default, handler: nil))
                                                            self?.present(alert, animated: true, completion: nil)
                                                        }
                                                        guard let strongSelf = self,
                                                              strongSelf.hasBook,
                                                              let start = strongSelf.startPageTextField?.page,
                                                              let finish = strongSelf.finishPageTextField?.page,
                                                              start < finish,
                                                              let bookModel = strongSelf.bookModel,
                                                              let autoTime = strongSelf.sessionButton?.time,
                                                              let handTime = strongSelf.handTimerView?.time,
                                                              let state = strongSelf.sessionButton?.buttonState,
                                                              (strongSelf.isAutomaticTimeCounterEnabled && autoTime > 0) ||
                                                              (!strongSelf.isAutomaticTimeCounterEnabled && handTime > 0),
                                                              (strongSelf.isAutomaticTimeCounterEnabled && (state == .pause)) ||
                                                              (!strongSelf.isAutomaticTimeCounterEnabled) else {
                                                                showError()
                                                                return
                                                        }
                                                        
                                                        let time = strongSelf.isAutomaticTimeCounterEnabled ? autoTime : handTime
                                                        
                                                        let vc = SessionFinishViewController()
                                                        vc.model = SessionFinishModel(bookInfo: bookModel,
                                                                                      startPage: start,
                                                                                      finishPage: finish,
                                                                                      time: time)
                                                        
                                                        strongSelf.navigationController?.pushViewController(vc, animated: true)
                                                    })))
        navBar.backgroundColor = UIColor(rgb: 0x2f5870)
        
        view.addSubview(navBar)
        navBar.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .bottom)
        self.navBar = navBar
        
        let bookCell = BookFilledCell(frame: .zero)
        if let bookModel = bookModel {
            bookCell.configure(model: bookModel)
        }
        
        view.addSubview(bookCell)
        bookCell.autoPinEdge(toSuperviewEdge: .left)
        bookCell.autoPinEdge(toSuperviewEdge: .right)
        bookCell.autoPinEdge(.top, to: .bottom, of: navBar)
        
        let bookEmptyCell = BookEmptyCell(frame: .zero)
        
        view.addSubview(bookEmptyCell)
        bookEmptyCell.autoPinEdge(toSuperviewEdge: .left)
        bookEmptyCell.autoPinEdge(toSuperviewEdge: .right)
        bookEmptyCell.autoPinEdge(.top, to: .bottom, of: navBar)
        bookEmptyCell.onAdd = { [weak self] in
            let vc = AddBookViewController()
            vc.onCompleted = { [weak self] bookModel in
                self?.updateWithBook(book: bookModel)
                self?.onBookAddedInSession?(bookModel)
            }
            self?.navigationController?.pushViewController(vc, animated: true)
        }
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
        
        self.bookEmptyCell = bookEmptyCell
        self.bookCell = bookCell
        self.finishPageTextField = finishPageTextField
        self.startPageTextField = startPageTextField
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
        super.viewWillAppear(animated)
    }
    
    func updateWithBook(book: BookModel) {
        bookModel = book
        bookCell?.configure(model: book)
        hasBook = true
    }
}
