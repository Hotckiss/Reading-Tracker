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
    let mainTabBarController = UITabBarController()
    var interactor: MainInteractor?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        view.backgroundColor = .white
        
        setupSubviews()
        setupSpinner()
        
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
    
    private func setupSubviews() {
        
        let profileVC = ProfileViewController()
        let libraryVC = MyBooksViewController()
        let statsVC = StatisticsViewController()
        
        profileVC.tabBarItem = UITabBarItem(title: nil, image: UIImage(named: "profileUnselected"), selectedImage: UIImage(named: "profileSelected"))
        profileVC.tabBarItem.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
        libraryVC.tabBarItem = UITabBarItem(title: nil, image: UIImage(named: "libraryUnselected"), selectedImage: UIImage(named: "librarySelected"))
        libraryVC.tabBarItem.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
        statsVC.tabBarItem = UITabBarItem(title: nil, image: UIImage(named: "statsUnselected"), selectedImage: UIImage(named: "statsSelected"))
        statsVC.tabBarItem.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
        
        let controllers = [profileVC, libraryVC, statsVC]
        
        mainTabBarController.viewControllers = controllers.map{ UINavigationController.init(rootViewController: $0)}
        
        mainTabBarController.tabBar.barTintColor = UIColor(rgb: 0x2f5870)
        mainTabBarController.tabBar.tintColor = .white
        navigationController?.pushViewController(mainTabBarController, animated: false)
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
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
}

