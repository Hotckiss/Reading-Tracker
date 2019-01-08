//
//  EditSessionTimeViewController.swift
//  Reading Tracker
//
//  Created by Andrei Kirilenko on 08/01/2019.
//  Copyright © 2019 Andrei Kirilenko. All rights reserved.
//

import Foundation
import UIKit

final class EditSessionTimeViewController: UIViewController {
    private var spinner: SpinnerView?
    private var navBar: NavigationBar?
    private var bookCell: BookFilledCell?
    private var finishButton: UIButton?
    private var handDateInputView: HandDateInputView?
    private var bookModel: BookModel = BookModel()
    private var startTime = Date()
    private var finishTime = Date()
    private var sessionId = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        var bottomSpace: CGFloat = 49
        if #available(iOS 11.0, *) {
            bottomSpace += UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
        }
        
        let navBar = NavigationBar()
        navBar.configure(model: NavigationBarModel(title: "Запись о чтении",
                                                   backButtonText: "Назад",
                                                   onBackButtonPressed: ({ [weak self] in
                                                    self?.navigationController?.popViewController(animated: true)
                                                   })))
        navBar.backgroundColor = UIColor(rgb: 0x2f5870)
        
        view.addSubview(navBar)
        navBar.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .bottom)
        self.navBar = navBar
        
        let bookCell = BookFilledCell(frame: .zero)
        bookCell.layer.shadowColor = UIColor.black.cgColor
        bookCell.layer.shadowOpacity = 0.2
        bookCell.layer.shadowOffset = CGSize(width: 0.0, height: 3.0)
        
        view.addSubview(bookCell)
        bookCell.autoPinEdge(toSuperviewEdge: .left)
        bookCell.autoPinEdge(toSuperviewEdge: .right)
        bookCell.autoPinEdge(.top, to: .bottom, of: navBar)
        bookCell.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onBookCellTap)))
        self.bookCell = bookCell
        
        let finishButton = UIButton(forAutoLayout: ())
        
        let finishButtonTextAttributes = [
            NSAttributedString.Key.foregroundColor : UIColor.white,
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: 20)]
            as [NSAttributedString.Key : Any]
        
        finishButton.setAttributedTitle(NSAttributedString(string: "Сохранить", attributes: finishButtonTextAttributes), for: .normal)
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
        
        let handDateInputView = HandDateInputView(frame: .zero)
        view.addSubview(handDateInputView)
        handDateInputView.autoPinEdge(.top, to: .bottom, of: bookCell, withOffset: SizeDependent.instance.convertPadding(20))
        handDateInputView.autoAlignAxis(toSuperviewAxis: .vertical)
        handDateInputView.autoSetDimension(.width, toSize: min(326, UIScreen.main.bounds.width))
        self.handDateInputView = handDateInputView
        setupSpinner()
        configure(book: self.bookModel, startDate: self.startTime, finishDate: self.finishTime, sessionId: self.sessionId)
    }
    
    @objc private func onFinishButtonTapped() {
        spinner?.show()
        guard let model = generateModel() else {
            return
        }
        
        FirestoreManager.DBManager.updateSessionTime(sessionId: sessionId,
                                                     session: model,
                                                     completion: ({ [weak self] in
                                                        //TODO: throw updated time to stats
                                                        self?.navigationController?.popViewController(animated: true)
                                                     }), onError: ({ [weak self] in
                                                        self?.showError(msg: "Ошибка загрузки сессии")
                                                     }))
    }
    
    @objc private func onBookCellTap() {
        //TODO: edit book?
    }
    
    private func generateModel() -> SessionFinishModel? {
        guard !sessionId.isEmpty,
            let (handStartDate, handFinishDate, handTime) = handDateInputView?.getDates() else {
                showError(msg: "Не все поля заполнены")
                return nil
        }
        
        return SessionFinishModel(bookInfo: bookModel,
                                  time: handTime,
                                  startTime: handStartDate,
                                  finishTime: handFinishDate)
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
    
    func configure(book: BookModel, startDate: Date, finishDate: Date, sessionId: String) {
        self.sessionId = sessionId
        self.bookModel = book
        self.startTime = startDate
        self.finishTime = finishDate
        bookCell?.configure(model: book)
        handDateInputView?.configure(startDateTime: startDate, finishDateTime: finishDate, date: startDate)
    }
    
    func updateWithBook(book: BookModel?) {
        spinner?.hide()
        if let book = book {
            bookModel = book
            bookCell?.configure(model: book)
        }
    }
}
