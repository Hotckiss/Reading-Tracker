//
//  BookTextSearchViewController.swift
//  Reading Tracker
//
//  Created by Andrei Kirilenko on 06/01/2019.
//  Copyright © 2019 Andrei Kirilenko. All rights reserved.
//

import Foundation
import PureLayout
import RxSwift
import Firebase

class BookTextSearchViewController: UIViewController {
    private var spinner: SpinnerView?
    private var searchTextField: RTTextField?
    private let searchTextFieldDelegate = FinishTextFieldDelegate()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupSubviews()
    }
    
    private func setupSubviews() {
        let navBar = NavigationBar(frame: .zero)
        navBar.configure(model: NavigationBarModel(title: "Поиск книги",
                                                   backButtonText: "Назад",
                                                   onBackButtonPressed: ({ [weak self] in
                                                    self?.navigationController?.popViewController(animated: true)
                                                   })
        ))
        navBar.backgroundColor = UIColor(rgb: 0x2f5870)
        view.addSubview(navBar)
        navBar.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .bottom)
        
        let spinner = SpinnerView()
        view.addSubview(spinner)
        
        spinner.autoCenterInSuperview()
        self.spinner = spinner
        
        let iconView = UIImageView(image: UIImage(named: "search"))
        view.addSubview(iconView)
        iconView.autoSetDimensions(to: CGSize(width: 22, height: 22))
        iconView.autoPinEdge(.top, to: .bottom, of: navBar, withOffset: 64)
        iconView.autoPinEdge(toSuperviewEdge: .left, withInset: 16)
        
        let placeholderTextAttributes = [
            NSAttributedString.Key.foregroundColor : UIColor(rgb: 0x2f5870).withAlphaComponent(0.5),
            NSAttributedString.Key.font : UIFont(name: "Avenir-Light", size: 20.0)!]
            as [NSAttributedString.Key : Any]
        
        let searchTextField = RTTextField(padding: .zero)
        searchTextField.attributedPlaceholder = NSAttributedString(string: "Название книги", attributes: placeholderTextAttributes)
        searchTextField.backgroundColor = .clear
        searchTextField.autocorrectionType = .no
        searchTextField.delegate = searchTextFieldDelegate
        searchTextField.returnKeyType = .done
        
        view.addSubview(searchTextField)
        searchTextField.autoAlignAxis(.horizontal, toSameAxisOf: iconView)
        searchTextField.autoPinEdge(.left, to: .right, of: iconView, withOffset: 8)
        searchTextField.autoPinEdge(toSuperviewEdge: .right, withInset: 16)
        
        self.searchTextField = searchTextField
        
        let lineView = UIView(frame: .zero)
        lineView.backgroundColor = UIColor(rgb: 0x2f5870).withAlphaComponent(0.5)
        
        view.addSubview(lineView)
        lineView.autoPinEdge(.top, to: .bottom, of: searchTextField, withOffset: 8)
        lineView.autoPinEdge(toSuperviewEdge: .left, withInset: 16)
        lineView.autoPinEdge(toSuperviewEdge: .right, withInset: 16)
        lineView.autoSetDimension(.height, toSize: 1)
        
        let searchButton = UIButton(frame: .zero)
        
        let buttonTextAttributes = [
            NSAttributedString.Key.foregroundColor : UIColor.white,
            NSAttributedString.Key.font : UIFont(name: "Avenir-Medium", size: 20.0)!]
            as [NSAttributedString.Key : Any]
        
        searchButton.setAttributedTitle(NSAttributedString(string: "Найти", attributes: buttonTextAttributes), for: .normal)
        searchButton.backgroundColor = UIColor(rgb: 0x2f5870)
        searchButton.layer.cornerRadius = 32
        searchButton.layer.shadowRadius = 4
        searchButton.layer.shadowColor = UIColor(rgb: 0x2f5870).cgColor
        searchButton.layer.shadowOpacity = 0.33
        searchButton.layer.shadowOffset = CGSize(width: 0.0, height: 4.0)
        searchButton.addTarget(self, action: #selector(onSearchButtonTapped), for: .touchUpInside)
        view.addSubview(searchButton)
        searchButton.autoSetDimensions(to: CGSize(width: 155, height: 64))
        searchButton.autoAlignAxis(toSuperviewAxis: .vertical)
        searchButton.autoPinEdge(.top, to: .bottom, of: lineView, withOffset: 64)
        
    }
    
    @objc private func onSearchButtonTapped() {
        let text = searchTextField?.text ?? ""
        
        guard !text.isEmpty else {
            alertError(reason: "Введите непустой запрос")
            return 
        }
        
        let query = BookQuery(searchText: text,
         startIndex: 0,
         maxResults: 40,
         filter: .paidEbooks,
         orderBy: .relevance)
         spinner?.show()
        
         APIManager.instance.book.get(bookQuery: query) { [weak self] result in
            self?.spinner?.hide()
         //let response = BooksList.GetBooks.Response(result: result)
         //self?.presenter?.presentGetBooks(response: response)
         }
    }
    
    private func alertError(reason: String) {
        let alert = UIAlertController(title: "Ошибка!", message: reason, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ок", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
