//
//  MyBooksViewController.swift
//  Reading Tracker
//
//  Created by Andrei Kirilenko on 15.10.2018.
//  Copyright © 2018 Andrei Kirilenko. All rights reserved.
//

import Foundation
import UIKit

final class MyBooksViewController: UIViewController {
    private var spinner: UIActivityIndicatorView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        view.backgroundColor = .orange
        setupNavigationBar()
        setupSpinner()
    }
    
    private func setupNavigationBar() {
        let navBar = NavigationBar()
        
        navBar.configure(model: NavigationBarModel(title: "Библиотека", backButtonText: "назад", onBackButtonPressed: ({ [weak self] in
            self?.navigationController?.popViewController(animated: true)
        })))
        
        view.addSubview(navBar)
        navBar.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: UIApplication.shared.statusBarFrame.height, left: 0, bottom: 0, right: 0), excludingEdge: .bottom)
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
}
