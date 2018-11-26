//
//  StatisticsViewController.swift
//  Reading Tracker
//
//  Created by Andrei Kirilenko on 15.10.2018.
//  Copyright © 2018 Andrei Kirilenko. All rights reserved.
//

import Foundation
import UIKit

final class StatisticsViewController: UIViewController {
    private var spinner: UIActivityIndicatorView?
    private var navBar: NavigationBar!
    var contentView: UIScrollView = UIScrollView(frame: .zero)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        view.backgroundColor = .white
        setupNavigationBar()
        view.addSubview(contentView)
        contentView.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .top)
        contentView.autoPinEdge(.top, to: .bottom, of: navBar)
        setupSpinner()
        
        let overall = OverallStatsView(frame: .zero)
        view.addSubview(overall)
        overall.autoSetDimensions(to: SizeDependent.instance.convertSize(CGSize(width: 230, height: 230)))
        overall.autoCenterInSuperview()
        overall.update(booksCount: 7, minsCount: 7257, approachesCount: 213)
    }
    
    private func setupNavigationBar() {
        let navBar = NavigationBar()
        
        navBar.configure(model: NavigationBarModel(title: "Чтение", backButtonText: "Назад", onBackButtonPressed: ({ [weak self] in
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
}
