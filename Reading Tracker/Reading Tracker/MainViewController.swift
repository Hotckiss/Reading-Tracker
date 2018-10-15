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
        view.backgroundColor = UIColor(rgb: 0x232f6d)
        setupSubviews()
        setupSpinner()
    }
    
    func configureGreeting(text: String) {
        let textAttributes = [
            NSAttributedString.Key.foregroundColor : UIColor.white,
            NSAttributedString.Key.font : UIFont(name: "AvenirNext-Bold", size: 19.0)!]
            as [NSAttributedString.Key : Any]
        
        greetingLabel?.attributedText = NSAttributedString(string: text, attributes: textAttributes)
        greetingLabel?.alpha = 1
    }
    
    private func setupSubviews() {
        let greetingLabel = UILabel(forAutoLayout: ())
        let textAttributes = [
            NSAttributedString.Key.foregroundColor : UIColor.white,
            NSAttributedString.Key.font : UIFont(name: "AvenirNext-Bold", size: 19.0)!]
            as [NSAttributedString.Key : Any]
        
        greetingLabel.attributedText = NSAttributedString(string: "Добро пожловать, Незнакомый Гость!", attributes: textAttributes)
        greetingLabel.numberOfLines = 0
        greetingLabel.alpha = 0
        greetingLabel.textAlignment = .center
        view.addSubview(greetingLabel)
        greetingLabel.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: UIApplication.shared.statusBarFrame.height + 32, left: 16, bottom: 0, right: 16), excludingEdge: .bottom)
        self.greetingLabel = greetingLabel
        
        let newBookButton = UIButton(forAutoLayout: ())
        let buttonTextAttributes = [
            NSAttributedString.Key.foregroundColor : UIColor.white,
            NSAttributedString.Key.font : UIFont(name: "AvenirNext-Bold", size: 21.0)!]
            as [NSAttributedString.Key : Any]
        
        newBookButton.setAttributedTitle(NSAttributedString(string: "Добавить книгу", attributes: buttonTextAttributes), for: [])
        newBookButton.backgroundColor = .clear
        //newBookButton.layer.borderColor = UIColor.white.cgColor
        //newBookButton.layer.borderWidth = 2
        //newBookButton.layer.backgroundColor = UIColor.clear.cgColor
        addButtonBorder(button: newBookButton)
        newBookButton.addTarget(self, action: #selector(addNewButtonAction), for: .touchUpInside)
        
        view.addSubview(newBookButton)
        newBookButton.autoPinEdge(.top, to: .bottom, of: greetingLabel, withOffset: 32)
        newBookButton.autoPinEdge(toSuperviewEdge: .left, withInset: 16)
        newBookButton.autoPinEdge(toSuperviewEdge: .right, withInset: 16)
        newBookButton.autoSetDimension(.height, toSize: 56)
        
        
        let statisticsButton = UIButton(forAutoLayout: ())
        
        statisticsButton.setAttributedTitle(NSAttributedString(string: "Статистика чтения", attributes: buttonTextAttributes), for: [])
        statisticsButton.backgroundColor = .clear
        //statisticsButton.layer.borderColor = UIColor.white.cgColor
        //statisticsButton.layer.borderWidth = 2
        //statisticsButton.layer.cornerRadius = 28
        addButtonBorder(button: statisticsButton)
        statisticsButton.addTarget(self, action: #selector(statisticsButtonAction), for: .touchUpInside)
        
        view.addSubview(statisticsButton)
        statisticsButton.autoPinEdge(.top, to: .bottom, of: newBookButton, withOffset: 16)
        statisticsButton.autoPinEdge(toSuperviewEdge: .left, withInset: 16)
        statisticsButton.autoPinEdge(toSuperviewEdge: .right, withInset: 16)
        statisticsButton.autoSetDimension(.height, toSize: 56)
        
        let libraryButton = UIButton(forAutoLayout: ())
        
        libraryButton.setAttributedTitle(NSAttributedString(string: "Мои книги", attributes: buttonTextAttributes), for: [])
        libraryButton.backgroundColor = .clear
        //libraryButton.layer.borderColor = UIColor.white.cgColor
        //libraryButton.layer.borderWidth = 2
        //libraryButton.layer.cornerRadius = 28
        addButtonBorder(button: libraryButton)
        libraryButton.addTarget(self, action: #selector(libraryButtonAction), for: .touchUpInside)
        
        view.addSubview(libraryButton)
        libraryButton.autoPinEdge(.top, to: .bottom, of: statisticsButton, withOffset: 16)
        libraryButton.autoPinEdge(toSuperviewEdge: .left, withInset: 16)
        libraryButton.autoPinEdge(toSuperviewEdge: .right, withInset: 16)
        libraryButton.autoSetDimension(.height, toSize: 56)
        
        let sessionButton = UIButton(forAutoLayout: ())
        
        sessionButton.setAttributedTitle(NSAttributedString(string: "Читать!", attributes: buttonTextAttributes), for: [])
        sessionButton.backgroundColor = .clear
        //sessionButton.layer.borderColor = UIColor.white.cgColor
        //sessionButton.layer.borderWidth = 2
        //sessionButton.layer.cornerRadius = 28
        addButtonBorder(button: sessionButton)
        sessionButton.addTarget(self, action: #selector(sessionButtonAction), for: .touchUpInside)
        
        view.addSubview(sessionButton)
        sessionButton.autoPinEdge(.top, to: .bottom, of: libraryButton, withOffset: 16)
        sessionButton.autoPinEdge(toSuperviewEdge: .left, withInset: 16)
        sessionButton.autoPinEdge(toSuperviewEdge: .right, withInset: 16)
        sessionButton.autoSetDimension(.height, toSize: 56)
        
        let exitButton = UIButton(forAutoLayout: ())
        
        exitButton.setAttributedTitle(NSAttributedString(string: "Выход", attributes: buttonTextAttributes), for: [])
        exitButton.backgroundColor = UIColor(rgb: 0xff7575)
        //exitButton.layer.borderColor = UIColor.white.cgColor
        //exitButton.layer.borderWidth = 2
        exitButton.layer.cornerRadius = 28
        addButtonBorder(button: exitButton)
        exitButton.addTarget(self, action: #selector(exitButtonAction), for: .touchUpInside)
        
        view.addSubview(exitButton)
        exitButton.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 0, left: 16, bottom: 16, right: 16), excludingEdge: .top)
        exitButton.autoSetDimension(.height, toSize: 56)
    }
    
    private func addButtonBorder(button: UIButton) {
        let gradient = CAGradientLayer()
        gradient.frame =  CGRect(origin: .zero, size: CGSize(width: view.bounds.width - 2 * 16, height: 56))
        gradient.colors = [UIColor.white.cgColor, UIColor(rgb: 0x7c0421).cgColor, UIColor(rgb: 0x63c87a).cgColor, UIColor.gray.cgColor, UIColor.white.cgColor]
        let shape = CAShapeLayer()
        shape.lineWidth = 3
        shape.path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: view.bounds.width - 2 * 16, height: 56), cornerRadius: 28).cgPath
        shape.cornerRadius = 28
        shape.strokeColor = UIColor.black.cgColor
        shape.fillColor = UIColor.clear.cgColor
        gradient.mask = shape
        gradient.cornerRadius = 28
        button.layer.addSublayer(gradient)
    }
    
    @objc private func addNewButtonAction() {
        let vc = AddBookViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func statisticsButtonAction() {
        let vc = StatisticsViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func libraryButtonAction() {
        let vc = MyBooksViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func sessionButtonAction() {
        let vc = SessionViewController()
        navigationController?.pushViewController(vc, animated: true)
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
        super.viewWillAppear(animated)
        if let name = interactor?.userData?.firstName,
            !name.isEmpty {
            return
        }
        
        interactor?.checkLogin(onStartLoad: ({ [weak self] in
            self?.spinner?.startAnimating()
        }), onFinishLoad: ({ [weak self] in
            self?.spinner?.stopAnimating()
        }))
    }
}

