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
    private var bookEmptyCell: BookEmptyCell?
    private var bookCell: BookFilledCell?
    private var startPageTextField: PageTextField?
    private var finishPageTextField: PageTextField?
    private var handTimeInputButton: UIButton?
    private var handTimerView: HandTimerView?
    private var isAutomaticTimeCounterEnabled: Bool = true
    
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
        
        hasBook = false
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
                                                   frontButtonText: "",
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
        
        let bookEmptyCell = BookEmptyCell(frame: .zero)
        
        view.addSubview(bookEmptyCell)
        bookEmptyCell.autoPinEdge(toSuperviewEdge: .left)
        bookEmptyCell.autoPinEdge(toSuperviewEdge: .right)
        bookEmptyCell.autoPinEdge(.top, to: .bottom, of: navBar)
        bookEmptyCell.onAdd = { [weak self] in
            let vc = AddBookViewController()
            vc.onCompleted = { [weak self] bookModel, bookType in
                self?.bookCell?.configure(model: bookModel)
                self?.hasBook = true
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
    }
    
    private class BookEmptyCell: UIView {
        var onAdd: (() -> Void)?
        
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
            
            titleTextLabel.attributedText = NSAttributedString(string: "Для начала добавьте книгу, которую сейчас читаете", attributes: titleTextAttributes)
            titleTextLabel.numberOfLines = 0
            
            let addButton = UIButton(forAutoLayout: ())
            
            addButton.backgroundColor = UIColor(rgb: 0x2f5870)
            let icon = UIImage(named: "plus")
            addButton.imageEdgeInsets = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
            addButton.setImage(icon, for: [])
            addButton.addTarget(self, action: #selector(addBook), for: .touchUpInside)
            addButton.layer.cornerRadius = 30
            addButton.layer.shadowColor = UIColor.black.cgColor
            addButton.layer.shadowOpacity = 0.2
            addButton.layer.shadowOffset = CGSize(width: 0.0, height: 3.0)
            
            addSubview(titleTextLabel)
            
            titleTextLabel.autoPinEdge(toSuperviewEdge: .left, withInset: 16)
            titleTextLabel.autoPinEdge(toSuperviewEdge: .right, withInset: 16 + 70 + 16)
            titleTextLabel.autoPinEdge(toSuperviewEdge: .top, withInset: 20)
            titleTextLabel.autoPinEdge(toSuperviewEdge: .bottom, withInset: 16)
            
            addSubview(addButton)
            
            addButton.autoSetDimensions(to: CGSize(width: 60, height: 60))
            addButton.autoPinEdge(toSuperviewEdge: .right, withInset: 16)
            addButton.autoAlignAxis(toSuperviewAxis: .horizontal)
        }
        
        @objc private func addBook() {
            onAdd?()
        }
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
        
        func disable(disable: Bool) {
            textField.isEnabled = !disable
        }
    }
    
    private class HandTimerView: UIView {
        var hours = 0
        var minutes = 0
        private var hrsView: UILabel!
        private var minsView: UILabel!
        private var hrsUpTimer: Timer!
        private var hrsDownTimer: Timer!
        private var minsUpTimer: Timer!
        private var minsDownTimer: Timer!
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            let backgroundView = setupBackgroundView()
            setupTimerView(backgroundView: backgroundView)
            let style = NSMutableParagraphStyle()
            style.alignment = NSTextAlignment.center
            
            let textAttributes = [
                NSAttributedString.Key.foregroundColor : UIColor(rgb: 0x2f5870).withAlphaComponent(0.5),
                NSAttributedString.Key.font : UIFont(name: "Avenir-Light", size: 14.0)!,
                NSAttributedString.Key.paragraphStyle: style]
                
                as [NSAttributedString.Key : Any]
            let hrsUpButton = UIButton(forAutoLayout: ())
            let hrsUpLabel = UILabel(forAutoLayout: ())
            hrsUpLabel.attributedText = NSAttributedString(string: "час", attributes: textAttributes)
            let hrsUpImageView = UIImageView(image: UIImage(named: "timeUp"))
            
            hrsUpButton.addSubview(hrsUpLabel)
            hrsUpButton.addSubview(hrsUpImageView)
            addSubview(hrsUpButton)
            hrsUpLabel.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .top)
            hrsUpImageView.autoSetDimensions(to: CGSize(width: 12, height: 7.5))
            hrsUpImageView.autoAlignAxis(.vertical, toSameAxisOf: hrsUpLabel)
            hrsUpImageView.autoPinEdge(.bottom, to: .top, of: hrsUpLabel)
            hrsUpButton.autoSetDimensions(to: CGSize(width: 67, height: 36))
            hrsUpButton.autoAlignAxis(.vertical, toSameAxisOf: hrsView)
            hrsUpButton.autoPinEdge(.bottom, to: .top, of: backgroundView, withOffset: -4)
            
            let minsUpButton = UIButton(forAutoLayout: ())
            let minsUpLabel = UILabel(forAutoLayout: ())
            minsUpLabel.attributedText = NSAttributedString(string: "мин", attributes: textAttributes)
            let minsUpImageView = UIImageView(image: UIImage(named: "timeUp"))
            
            minsUpButton.addSubview(minsUpLabel)
            minsUpButton.addSubview(minsUpImageView)
            addSubview(minsUpButton)
            minsUpLabel.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .top)
            minsUpImageView.autoSetDimensions(to: CGSize(width: 12, height: 7.5))
            minsUpImageView.autoAlignAxis(.vertical, toSameAxisOf: minsUpLabel)
            minsUpImageView.autoPinEdge(.bottom, to: .top, of: minsUpLabel)
            minsUpButton.autoSetDimensions(to: CGSize(width: 67, height: 36))
            minsUpButton.autoAlignAxis(.vertical, toSameAxisOf: minsView)
            minsUpButton.autoPinEdge(.bottom, to: .top, of: backgroundView, withOffset: -4)
            
            let hrsDownButton = UIButton(forAutoLayout: ())
            let hrsDownLabel = UILabel(forAutoLayout: ())
            hrsDownLabel.attributedText = NSAttributedString(string: "час", attributes: textAttributes)
            let hrsDownImageView = UIImageView(image: UIImage(named: "timeDown"))
            
            hrsDownButton.addSubview(hrsDownLabel)
            hrsDownButton.addSubview(hrsDownImageView)
            addSubview(hrsDownButton)
            hrsDownLabel.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .bottom)
            hrsDownImageView.autoSetDimensions(to: CGSize(width: 12, height: 7.5))
            hrsDownImageView.autoAlignAxis(.vertical, toSameAxisOf: hrsDownLabel)
            hrsDownImageView.autoPinEdge(.top, to: .bottom, of: hrsDownLabel)
            hrsDownButton.autoSetDimensions(to: CGSize(width: 67, height: 36))
            hrsDownButton.autoAlignAxis(.vertical, toSameAxisOf: hrsView)
            hrsDownButton.autoPinEdge(.top, to: .bottom, of: backgroundView, withOffset: 4)
            
            let minsDownButton = UIButton(forAutoLayout: ())
            let minsDownLabel = UILabel(forAutoLayout: ())
            minsDownLabel.attributedText = NSAttributedString(string: "мин", attributes: textAttributes)
            let minsDownImageView = UIImageView(image: UIImage(named: "timeDown"))
            
            minsDownButton.addSubview(minsDownLabel)
            minsDownButton.addSubview(minsDownImageView)
            addSubview(minsDownButton)
            minsDownLabel.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .bottom)
            minsDownImageView.autoSetDimensions(to: CGSize(width: 12, height: 7.5))
            minsDownImageView.autoAlignAxis(.vertical, toSameAxisOf: minsDownLabel)
            minsDownImageView.autoPinEdge(.top, to: .bottom, of: minsDownLabel)
            minsDownButton.autoSetDimensions(to: CGSize(width: 67, height: 36))
            minsDownButton.autoAlignAxis(.vertical, toSameAxisOf: minsView)
            minsDownButton.autoPinEdge(.top, to: .bottom, of: backgroundView, withOffset: 4)
            
            hrsUpButton.addTarget(self, action: #selector(hrsUpStart), for: .touchDown)
            hrsUpButton.addTarget(self, action: #selector(hrsUpEnd), for: .touchUpInside)
            hrsDownButton.addTarget(self, action: #selector(hrsDownStart), for: .touchDown)
            hrsDownButton.addTarget(self, action: #selector(hrsDownEnd), for: .touchUpInside)
            
            minsUpButton.addTarget(self, action: #selector(minsUpStart), for: .touchDown)
            minsUpButton.addTarget(self, action: #selector(minsUpEnd), for: .touchUpInside)
            minsDownButton.addTarget(self, action: #selector(minsDownStart), for: .touchDown)
            minsDownButton.addTarget(self, action: #selector(minsDownEnd), for: .touchUpInside)
        }
        
        @objc private func hrsUpStart() {
            hrsUpFire()
            hrsUpTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(hrsUpFire), userInfo: nil, repeats: true)
        }
        
        @objc private func hrsUpEnd() {
            hrsUpTimer.invalidate()
        }
        
        @objc private func hrsUpFire() {
            hours = (hours + 1) % 24
            setTime(hrsLabel: hrsView, minsLabel: minsView)
        }
        
        @objc private func hrsDownStart() {
            hrsDownFire()
            hrsDownTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(hrsDownFire), userInfo: nil, repeats: true)
        }
        
        @objc private func hrsDownEnd() {
            hrsDownTimer.invalidate()
        }
        
        @objc private func hrsDownFire() {
            hours = (hours + 24 - 1) % 24
            setTime(hrsLabel: hrsView, minsLabel: minsView)
        }
        
        @objc private func minsUpStart() {
            minsUpFire()
            minsUpTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(minsUpFire), userInfo: nil, repeats: true)
        }
        
        @objc private func minsUpEnd() {
            minsUpTimer.invalidate()
        }
        
        @objc private func minsUpFire() {
            minutes = (minutes + 1) % 60
            setTime(hrsLabel: hrsView, minsLabel: minsView)
        }
        
        @objc private func minsDownStart() {
            minsDownFire()
            minsDownTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(minsDownFire), userInfo: nil, repeats: true)
        }
        
        @objc private func minsDownEnd() {
            minsDownTimer.invalidate()
        }
        
        @objc private func minsDownFire() {
            minutes = (minutes + 60 - 1) % 60
            setTime(hrsLabel: hrsView, minsLabel: minsView)
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private func setupBackgroundView() -> UIView {
            let backgroundView = UIView(forAutoLayout: ())
            
            backgroundView.backgroundColor = .white
            backgroundView.layer.cornerRadius = 40
            backgroundView.layer.shadowOffset = CGSize(width: 0, height: 3)
            backgroundView.layer.shadowColor = UIColor.black.cgColor
            backgroundView.layer.shadowOpacity = 0.2
            backgroundView.layer.shadowRadius = 3
            
            addSubview(backgroundView)
            backgroundView.autoPinEdge(toSuperviewEdge: .left)
            backgroundView.autoPinEdge(toSuperviewEdge: .right)
            backgroundView.autoSetDimension(.height, toSize: 80)
            backgroundView.autoPinEdge(toSuperviewEdge: .bottom, withInset: 27 + 4)
            
            return backgroundView
        }
        
        private func setupTimerView(backgroundView: UIView) {
            let hrsView = UILabel(forAutoLayout: ())
            let minsView = UILabel(forAutoLayout: ())
            let dotsView = UILabel(forAutoLayout: ())
            hrsView.textAlignment = .center
            minsView.textAlignment = .center
            dotsView.textAlignment = .center
            
            let timerTextAttributes = [
                NSAttributedString.Key.foregroundColor : UIColor(rgb: 0x2f5870),
                NSAttributedString.Key.font : UIFont(name: "Avenir-Light", size: 64.0)!,
                NSAttributedString.Key.baselineOffset: 4]
                as [NSAttributedString.Key : Any]
            
            dotsView.attributedText = NSAttributedString(string: ":", attributes: timerTextAttributes)
            setTime(hrsLabel: hrsView, minsLabel: minsView)
            backgroundView.addSubview(dotsView)
            dotsView.autoCenterInSuperview()
            
            backgroundView.addSubview(hrsView)
            hrsView.autoAlignAxis(toSuperviewAxis: .horizontal)
            hrsView.autoPinEdge(toSuperviewEdge: .left, withInset: 16)
            hrsView.autoSetDimension(.width, toSize: 67)
            
            backgroundView.addSubview(minsView)
            minsView.autoAlignAxis(toSuperviewAxis: .horizontal)
            minsView.autoPinEdge(toSuperviewEdge: .right, withInset: 16)
            minsView.autoSetDimension(.width, toSize: 67)
            
            self.hrsView = hrsView
            self.minsView = minsView
        }
        
        private func setTime(hrsLabel: UILabel, minsLabel: UILabel) {
            let timerTextAttributes = [
                NSAttributedString.Key.foregroundColor : UIColor(rgb: 0x2f5870),
                NSAttributedString.Key.font : UIFont(name: "Avenir-Light", size: 64.0)!]
                as [NSAttributedString.Key : Any]
            
            hrsLabel.attributedText = NSAttributedString(string: "\(hours)", attributes: timerTextAttributes)
            minsLabel.attributedText = NSAttributedString(string: "\(minutes)", attributes: timerTextAttributes)
        }
    }
}
