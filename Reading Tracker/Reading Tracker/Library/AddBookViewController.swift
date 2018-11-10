//
//  AddBookViewController.swift
//  Reading Tracker
//
//  Created by Andrei Kirilenko on 15.10.2018.
//  Copyright © 2018 Andrei Kirilenko. All rights reserved.
//

import Foundation
import UIKit

final class AddBookViewController: UIViewController {
    private var spinner: UIActivityIndicatorView?
    private var navBar: NavigationBar?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupNavigationBar()
        setupSpinner()
        
        let placeholderTextAttributes = [
            NSAttributedString.Key.foregroundColor : UIColor(rgb: 0x2f5870).withAlphaComponent(0.5),
            NSAttributedString.Key.font : UIFont(name: "Avenir-Light", size: 20.0)!]
            as [NSAttributedString.Key : Any]
        
        let nameTextField = RTTextField(padding: .zero)
        nameTextField.attributedPlaceholder = NSAttributedString(string: "Название книги", attributes: placeholderTextAttributes)
        nameTextField.backgroundColor = .clear
        nameTextField.autocorrectionType = .no
        //nameTextField.delegate = nil
        nameTextField.returnKeyType = .continue
        
        view.addSubview(nameTextField)
        nameTextField.autoAlignAxis(toSuperviewAxis: .vertical)
        nameTextField.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 124, left: 16, bottom: 0, right: 16), excludingEdge: .bottom)
        
        let lineView = UIView(frame: .zero)
        lineView.backgroundColor = UIColor(rgb: 0x2f5870).withAlphaComponent(0.5)
        
        view.addSubview(lineView)
        lineView.autoPinEdge(.top, to: .bottom, of: nameTextField, withOffset: 8)
        lineView.autoPinEdge(toSuperviewEdge: .left, withInset: 16)
        lineView.autoPinEdge(toSuperviewEdge: .right, withInset: 16)
        lineView.autoSetDimension(.height, toSize: 1)
        
        let authorTextField = RTTextField(padding: .zero)
        authorTextField.attributedPlaceholder = NSAttributedString(string: "Автор", attributes: placeholderTextAttributes)
        authorTextField.backgroundColor = .clear
        authorTextField.autocorrectionType = .no
        //authorTextField.delegate = nil
        authorTextField.returnKeyType = .continue
        
        view.addSubview(authorTextField)
        authorTextField.autoAlignAxis(toSuperviewAxis: .vertical)
        authorTextField.autoPinEdge(toSuperviewEdge: .left, withInset: 16)
        authorTextField.autoPinEdge(toSuperviewEdge: .right, withInset: 16)
        authorTextField.autoPinEdge(.top, to: .bottom, of: lineView, withOffset: 59)
        
        let lineView2 = UIView(frame: .zero)
        lineView2.backgroundColor = UIColor(rgb: 0x2f5870).withAlphaComponent(0.5)
        
        view.addSubview(lineView2)
        lineView2.autoPinEdge(.top, to: .bottom, of: authorTextField, withOffset: 8)
        lineView2.autoPinEdge(toSuperviewEdge: .left, withInset: 16)
        lineView2.autoPinEdge(toSuperviewEdge: .right, withInset: 16)
        lineView2.autoSetDimension(.height, toSize: 1)
        
        let bookTypes =  ["Медиа", "Бумажная книга", "Элекронная книга", "Смартфон"]
        let mediaDropdown = DropdownMenu(frame: .zero, optionsList: bookTypes)
        view.addSubview(mediaDropdown)
        mediaDropdown.autoPinEdge(toSuperviewEdge: .left, withInset: 16)
        mediaDropdown.autoPinEdge(toSuperviewEdge: .right, withInset: 16)
        mediaDropdown.autoPinEdge(.top, to: .bottom, of: lineView2, withOffset: 59)
        mediaDropdown.autoSetDimension(.height, toSize: 32 * CGFloat(bookTypes.count))
    }
    
    private func setupNavigationBar() {
        let navBar = NavigationBar()
        navBar.configure(model: NavigationBarModel(title: "Новая книга", backButtonText: "Назад", frontButtonText: "Готово", onBackButtonPressed: ({ [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }), onFrontButtonPressed: ({ [weak self] in
            self?.navigationController?.popViewController(animated: true)
        })))
        navBar.backgroundColor = UIColor(rgb: 0x2f5870)
        view.addSubview(navBar)
        navBar.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .bottom)
        self.navBar = navBar
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
    
    private class DropdownMenu: UIView {
        var selectedIndex: Int
        private var optionsList: [String]
        private var mainOptionIndex: Int
        private var buttons: [UIButton] = []
        private var isExpanded = false
        init(frame: CGRect, optionsList: [String], mainOptionIndex: Int = 0) {
            self.optionsList = optionsList
            self.mainOptionIndex = mainOptionIndex
            self.selectedIndex = mainOptionIndex
            super.init(frame: frame)
            
            setupSubviews()
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private func setupSubviews() {
            let mainTextAttributes = [
                NSAttributedString.Key.foregroundColor : UIColor(rgb: 0x2f5870).withAlphaComponent(0.5),
                NSAttributedString.Key.font : UIFont(name: "Avenir-Light", size: 20.0)!]
                as [NSAttributedString.Key : Any]
            
            let textAttributes = [
                NSAttributedString.Key.foregroundColor : UIColor(rgb: 0x2f5870),
                NSAttributedString.Key.font : UIFont(name: "Avenir-Medium", size: 20.0)!]
                as [NSAttributedString.Key : Any]
            
            let mainButton = UIButton(forAutoLayout: ())
            mainButton.setAttributedTitle(NSAttributedString(string: optionsList[mainOptionIndex], attributes: mainTextAttributes), for: [])
            mainButton.contentHorizontalAlignment = .left
            addSubview(mainButton)
            mainButton.autoSetDimension(.height, toSize: 32)
            mainButton.autoPinEdge(toSuperviewEdge: .left)
            mainButton.autoPinEdge(toSuperviewEdge: .right)
            mainButton.autoPinEdge(toSuperviewEdge: .top)
            
            mainButton.addTarget(self, action: #selector(mainButtonTap), for: .touchUpInside)
            
            let arrowImageView = UIImageView(image: UIImage(named: "down"))
            mainButton.addSubview(arrowImageView)
            arrowImageView.autoSetDimensions(to: CGSize(width: 10, height: 5))
            arrowImageView.autoAlignAxis(toSuperviewAxis: .horizontal)
            arrowImageView.autoPinEdge(toSuperviewEdge: .right)
            
            var lastButton = mainButton
            
            buttons.append(mainButton)
            for i in 1..<optionsList.count {
                let button = IndexedButton(frame: .zero, index: i)
                button.setAttributedTitle(NSAttributedString(string: optionsList[i], attributes: textAttributes), for: [])
                button.contentHorizontalAlignment = .left
                addSubview(button)
                button.autoSetDimension(.height, toSize: 32)
                button.autoPinEdge(toSuperviewEdge: .left)
                button.autoPinEdge(toSuperviewEdge: .right)
                button.autoPinEdge(.top, to: .bottom, of: lastButton)
                button.isHidden = !isExpanded
                button.addTarget(self, action: #selector(buttonTap(_:)), for: .touchUpInside)
                buttons.append(button)
                lastButton = button
            }
        }
        
        @objc private func buttonTap(_ sender: IndexedButton) {
            let textAttributes = [
                NSAttributedString.Key.foregroundColor : UIColor(rgb: 0x2f5870),
                NSAttributedString.Key.font : UIFont(name: "Avenir-Medium", size: 20.0)!]
                as [NSAttributedString.Key : Any]
            buttons[mainOptionIndex].setAttributedTitle(NSAttributedString(string: optionsList[sender.index], attributes: textAttributes), for: [])
            isExpanded = false
            selectedIndex = sender.index
            updateExpand()
        }
        
        @objc private func mainButtonTap() {
            isExpanded = !isExpanded
            updateExpand()
        }
        
        private func updateExpand() {
            for i in 0..<buttons.count {
                if i != mainOptionIndex {
                    buttons[i].isHidden = !isExpanded
                }
            }
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
