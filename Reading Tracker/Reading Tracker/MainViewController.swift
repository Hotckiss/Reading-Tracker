//
//  MainViewController.swift
//  Reading Tracker
//
//  Created by Andrei Kirilenko on 23.09.2018.
//  Copyright © 2018 Andrei Kirilenko. All rights reserved.
//

import UIKit
import PureLayout
import RxSwift
import Firebase

final class MainViewController: UIViewController {
    private var spinner: UIActivityIndicatorView?
    private var greetingLabel: UILabel?
    
    var interactor: MainInteractor?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        view.backgroundColor = .orange
        setupSubviews()
        setupSpinner()
    }
    
    func configureGreeting(text: String) {
        let textAttributes = [
            NSAttributedString.Key.foregroundColor : UIColor(rgb: 0x1f1f1f),
            NSAttributedString.Key.font : UIFont(name: "AvenirNext-Bold", size: 19.0)!]
            as [NSAttributedString.Key : Any]
        
        greetingLabel?.attributedText = NSAttributedString(string: text, attributes: textAttributes)
        greetingLabel?.alpha = 1
    }
    
    private func setupSubviews() {
        let greetingLabel = UILabel(forAutoLayout: ())
        let textAttributes = [
            NSAttributedString.Key.foregroundColor : UIColor(rgb: 0x1f1f1f),
            NSAttributedString.Key.font : UIFont(name: "AvenirNext-Bold", size: 19.0)!]
            as [NSAttributedString.Key : Any]
        
        greetingLabel.attributedText = NSAttributedString(string: "Добро пожловать, Незнакомый Гость!", attributes: textAttributes)
        greetingLabel.numberOfLines = 0
        greetingLabel.alpha = 0
        greetingLabel.textAlignment = .center
        view.addSubview(greetingLabel)
        greetingLabel.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: UIApplication.shared.statusBarFrame.height + 32, left: 32, bottom: 0, right: 32), excludingEdge: .bottom)
        self.greetingLabel = greetingLabel
        
        let newBookButton = UIButton(forAutoLayout: ())
        let buttonTextAttributes = [
            NSAttributedString.Key.foregroundColor : UIColor(rgb: 0x1f1f1f),
            NSAttributedString.Key.font : UIFont(name: "AvenirNext-Bold", size: 21.0)!]
            as [NSAttributedString.Key : Any]
        
        newBookButton.setAttributedTitle(NSAttributedString(string: "Добавить книгу", attributes: buttonTextAttributes), for: [])
        newBookButton.backgroundColor = UIColor(rgb: 0x75ff75)
        newBookButton.layer.borderColor = UIColor(rgb: 0x1f1f1f).cgColor
        newBookButton.layer.borderWidth = 2
        newBookButton.layer.cornerRadius = 8
        newBookButton.addTarget(self, action: #selector(addNewButtonAction), for: .touchUpInside)
        
        view.addSubview(newBookButton)
        newBookButton.autoPinEdge(.top, to: .bottom, of: greetingLabel, withOffset: 32)
        newBookButton.autoPinEdge(toSuperviewEdge: .left, withInset: 32)
        newBookButton.autoPinEdge(toSuperviewEdge: .right, withInset: 32)
        newBookButton.autoSetDimension(.height, toSize: 56)
        
        
        let statisticsButton = UIButton(forAutoLayout: ())
        
        statisticsButton.setAttributedTitle(NSAttributedString(string: "Статистика чтения", attributes: buttonTextAttributes), for: [])
        statisticsButton.backgroundColor = UIColor(rgb: 0x75ff75)
        statisticsButton.layer.borderColor = UIColor(rgb: 0x1f1f1f).cgColor
        statisticsButton.layer.borderWidth = 2
        statisticsButton.layer.cornerRadius = 8
        statisticsButton.addTarget(self, action: #selector(statisticsButtonAction), for: .touchUpInside)
        
        view.addSubview(statisticsButton)
        statisticsButton.autoPinEdge(.top, to: .bottom, of: newBookButton, withOffset: 16)
        statisticsButton.autoPinEdge(toSuperviewEdge: .left, withInset: 32)
        statisticsButton.autoPinEdge(toSuperviewEdge: .right, withInset: 32)
        statisticsButton.autoSetDimension(.height, toSize: 56)
        
        let libraryButton = UIButton(forAutoLayout: ())
        
        libraryButton.setAttributedTitle(NSAttributedString(string: "Мои книги", attributes: buttonTextAttributes), for: [])
        libraryButton.backgroundColor = UIColor(rgb: 0x75ff75)
        libraryButton.layer.borderColor = UIColor(rgb: 0x1f1f1f).cgColor
        libraryButton.layer.borderWidth = 2
        libraryButton.layer.cornerRadius = 8
        libraryButton.addTarget(self, action: #selector(libraryButtonAction), for: .touchUpInside)
        
        view.addSubview(libraryButton)
        libraryButton.autoPinEdge(.top, to: .bottom, of: statisticsButton, withOffset: 16)
        libraryButton.autoPinEdge(toSuperviewEdge: .left, withInset: 32)
        libraryButton.autoPinEdge(toSuperviewEdge: .right, withInset: 32)
        libraryButton.autoSetDimension(.height, toSize: 56)
        
        let sessionButton = UIButton(forAutoLayout: ())
        
        sessionButton.setAttributedTitle(NSAttributedString(string: "Читать!", attributes: buttonTextAttributes), for: [])
        sessionButton.backgroundColor = UIColor(rgb: 0x75ff75)
        sessionButton.layer.borderColor = UIColor(rgb: 0x1f1f1f).cgColor
        sessionButton.layer.borderWidth = 2
        sessionButton.layer.cornerRadius = 8
        sessionButton.addTarget(self, action: #selector(sessionButtonAction), for: .touchUpInside)
        
        view.addSubview(sessionButton)
        sessionButton.autoPinEdge(.top, to: .bottom, of: libraryButton, withOffset: 16)
        sessionButton.autoPinEdge(toSuperviewEdge: .left, withInset: 32)
        sessionButton.autoPinEdge(toSuperviewEdge: .right, withInset: 32)
        sessionButton.autoSetDimension(.height, toSize: 56)
        
        let exitButton = UIButton(forAutoLayout: ())
        
        exitButton.setAttributedTitle(NSAttributedString(string: "Выход", attributes: buttonTextAttributes), for: [])
        exitButton.backgroundColor = UIColor(rgb: 0xff7575)
        exitButton.layer.borderColor = UIColor(rgb: 0x1f1f1f).cgColor
        exitButton.layer.borderWidth = 2
        exitButton.layer.cornerRadius = 8
        exitButton.addTarget(self, action: #selector(exitButtonAction), for: .touchUpInside)
        
        view.addSubview(exitButton)
        exitButton.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 0, left: 32, bottom: 16, right: 32), excludingEdge: .top)
        exitButton.autoSetDimension(.height, toSize: 56)
    }
    
    @objc private func addNewButtonAction() {
        print("1")
    }
    
    @objc private func statisticsButtonAction() {
        print("2")
    }
    
    @objc private func libraryButtonAction() {
        print("3")
    }
    
    @objc private func sessionButtonAction() {
        print("4")
    }
    
    @objc private func exitButtonAction() {
        do {
            try Auth.auth().signOut()
        } catch {
            print("Exit error occured")
        }
        
        interactor?.checkLogin(onStartLoad: ({ [weak self] in
            self?.spinner?.startAnimating()
        }), onFinishLoad: ({ [weak self] in
            self?.spinner?.stopAnimating()
        }))
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
        interactor?.checkLogin(onStartLoad: ({ [weak self] in
            self?.spinner?.startAnimating()
        }), onFinishLoad: ({ [weak self] in
            self?.spinner?.stopAnimating()
        }))
    }
}

