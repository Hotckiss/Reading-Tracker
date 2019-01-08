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
    var onSessionUploaded: ((UploadSessionModel) -> Void)?
    var onBookAddedInSession: ((BookModel) -> Void)?
    var onBookSelectFromLibraryRequest: (() -> Void)?
    private var spinner: SpinnerView?
    private var navBar: NavigationBar?
    private var sessionButton: SessionTimerButton?
    private var bookEmptyCell: BookEmptyCell?
    private var bookCell: BookFilledCell?
    private var handTimeInputButton: UIButton?
    private var finishButton: UIButton?
    private var finishButtonOverlay: UIView?
    private var handDateInputView: HandDateInputView?
    private var isAutomaticTimeCounterEnabled: Bool = true {
        didSet {
            finishButtonOverlay?.isHidden = !(isAutomaticTimeCounterEnabled && (sessionButton?.buttonState ?? .start) == .start)
        }
    }
    
    private var bookModel: BookModel?
    
    private var hasBook: Bool = false {
        didSet {
            bookEmptyCell?.isHidden = hasBook
            bookCell?.isHidden = !hasBook
            sessionButton?.isPlaceholder = !hasBook
            handTimeInputButton?.isHidden = !hasBook
            finishButton?.isHidden = !hasBook
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        view.backgroundColor = .white
        
        var bottomSpace: CGFloat = 49
        if #available(iOS 11.0, *) {
            bottomSpace += UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
        }
        
        let navBar = NavigationBar()
        navBar.configure(model: NavigationBarModel(title: "Новая запись о чтении",
                                                   onBackButtonPressed: ({
                                                    let alert = UIAlertController(title: "Сбросить сессию?", message: nil, preferredStyle: .alert)
                                                    alert.addAction(UIAlertAction(title: "Отмена", style: .default, handler: nil))
                                                    alert.addAction(UIAlertAction(title: "Сбросить", style: .destructive, handler: ({ [weak self] _ in
                                                        self?.reset()
                                                    })))
                                                    self.present(alert, animated: true, completion: nil)
                                                   })))
        navBar.backgroundColor = UIColor(rgb: 0x2f5870)
        navBar.setBackButtonImage(image: UIImage(named: "close"))
        view.addSubview(navBar)
        navBar.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .bottom)
        self.navBar = navBar
        
        let bookCell = BookFilledCell(frame: .zero)
        bookCell.layer.shadowColor = UIColor.black.cgColor
        bookCell.layer.shadowOpacity = 0.2
        bookCell.layer.shadowOffset = CGSize(width: 0.0, height: 3.0)
        if let bookModel = bookModel {
            bookCell.configure(model: bookModel)
        }
        
        view.addSubview(bookCell)
        bookCell.autoPinEdge(toSuperviewEdge: .left)
        bookCell.autoPinEdge(toSuperviewEdge: .right)
        bookCell.autoPinEdge(.top, to: .bottom, of: navBar)
        bookCell.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onBookCellTap)))
        let bookEmptyCell = BookEmptyCell(frame: .zero)
        self.bookCell = bookCell
        
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
        self.bookEmptyCell = bookEmptyCell
        
        let handTimeInputButton = UIButton(forAutoLayout: ())
        handTimeInputButton.addTarget(self, action: #selector(onHandTimeTap), for:.touchUpInside)
        view.addSubview(handTimeInputButton)
        handTimeInputButton.autoAlignAxis(toSuperviewAxis: .vertical)
        handTimeInputButton.autoPinEdge(.top, to: .bottom, of: bookCell, withOffset: SizeDependent.instance.convertPadding(30))
        self.handTimeInputButton = handTimeInputButton
        
        let sessionButton = SessionTimerButton(frame: .zero)
        sessionButton.onStateChanged = { [weak self] state in
            self?.finishButtonOverlay?.isHidden = !((self?.isAutomaticTimeCounterEnabled ?? true) && state == .start)
        }
        view.addSubview(sessionButton)
        sessionButton.autoPinEdge(.top, to: .bottom, of: handTimeInputButton, withOffset: SizeDependent.instance.convertPadding(20))
        sessionButton.autoAlignAxis(toSuperviewAxis: .vertical)
        sessionButton.autoSetDimensions(to: SizeDependent.instance.convertSize(CGSize(width: 230, height: 230)))
        sessionButton.addTarget(self, action: #selector(onSessionButtonTap), for: .touchUpInside)
        sessionButton.buttonState = .start
        self.sessionButton = sessionButton
        
        let finishButton = UIButton(forAutoLayout: ())
        
        let finishButtonTextAttributes = [
            NSAttributedString.Key.foregroundColor : UIColor.white,
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: 20)]
            as [NSAttributedString.Key : Any]
        
        finishButton.setAttributedTitle(NSAttributedString(string: "Завершить", attributes: finishButtonTextAttributes), for: .normal)
        finishButton.backgroundColor = UIColor(rgb: 0x2f5870)
        finishButton.layer.cornerRadius = SizeDependent.instance.convertDimension(30)
        finishButton.layer.shadowRadius = 4
        finishButton.layer.shadowColor = UIColor(rgb: 0x2f5870).cgColor
        finishButton.layer.shadowOpacity = 0.33
        finishButton.layer.shadowOffset = CGSize(width: 0.0, height: 4.0)
        finishButton.addTarget(self, action: #selector(onFinishButtonTapped), for: .touchUpInside)
        view.addSubview(finishButton)
        finishButton.autoSetDimensions(to: CGSize(width: 155, height: SizeDependent.instance.convertDimension(60)))
        finishButton.autoAlignAxis(toSuperviewAxis: .vertical)
        finishButton.autoPinEdge(toSuperviewEdge: .bottom, withInset: bottomSpace + SizeDependent.instance.convertPadding(20))
        
        let overlay = UIView(forAutoLayout: ())
        overlay.backgroundColor = .white
        overlay.alpha = 0.5
        overlay.layer.cornerRadius = SizeDependent.instance.convertDimension(30)
        finishButton.addSubview(overlay)
        overlay.autoPinEdgesToSuperviewEdges()
        self.finishButtonOverlay = overlay
        
        let handDateInputView = HandDateInputView(frame: .zero)
        view.addSubview(handDateInputView)
        handDateInputView.autoPinEdge(.top, to: .bottom, of: handTimeInputButton, withOffset: SizeDependent.instance.convertPadding(20))
        handDateInputView.autoAlignAxis(toSuperviewAxis: .vertical)
        handDateInputView.autoSetDimension(.width, toSize: min(326, UIScreen.main.bounds.width))
        self.handDateInputView = handDateInputView
        
        updateTimeInput(isHand: false)
        hasBook = (bookModel != nil)
        isAutomaticTimeCounterEnabled = true
        setupSpinner()
        spinner?.show()
    }
    
    @objc private func onFinishButtonTapped() {
        guard let finishModel = generateModel() else {
            return
        }
        
        let vc = SessionFinishViewController(model: finishModel)
        vc.onCompleted = { [weak self] usm in
            self?.onSessionUploaded?(usm)
            self?.handDateInputView?.reset()
            self?.sessionButton?.reset()
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func reset() {
        if hasBook {
            handDateInputView?.reset()
            sessionButton?.reset()
            isAutomaticTimeCounterEnabled = true
            updateTimeInput(isHand: !isAutomaticTimeCounterEnabled)
        }
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
        handDateInputView?.isHidden = !isHand
        sessionButton?.isHidden = isHand
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
    
    @objc private func onBookCellTap() {
        onBookSelectFromLibraryRequest?()
    }
    
    private func generateModel() -> SessionFinishModel? {
        if isAutomaticTimeCounterEnabled {
            guard hasBook,
                let bookModel = bookModel,
                let autoTime = sessionButton?.time,
                let state = sessionButton?.buttonState,
                state != .start,
                let startTime = sessionButton?.startTime else {
                    showError()
                    return nil
            }
            
            return SessionFinishModel(bookInfo: bookModel,
                                      time: autoTime,
                                      startTime: startTime)
        } else {
            guard hasBook,
                let bookModel = bookModel,
                let (handStartDate, handFinishDate, handTime) = handDateInputView?.getDates() else {
                    showError()
                    return nil
            }
            
            return SessionFinishModel(bookInfo: bookModel,
                                      time: handTime,
                                      startTime: handStartDate,
                                      finishTime: handFinishDate)
        }
    }
    
    private func showError() {
        let alert = UIAlertController(title: "Ошибка!", message: "Не все поля заполнены", preferredStyle: .alert)
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
    
    func updateWithBook(book: BookModel?) {
        spinner?.hide()
        if let book = book {
            bookModel = book
            bookCell?.configure(model: book)
            hasBook = true
        } else {
            hasBook = false
        }
    }
}
