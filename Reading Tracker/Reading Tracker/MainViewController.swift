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
    let mainTabBarController = AnimatedTabBarController()
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
            //self?.spinner?.startAnimating()
        }), onFinishLoad: ({ [weak self] in
            //self?.spinner?.stopAnimating()
        }))
    }
    
    private func setupSubviews() {
        
        let profileVC = ProfileViewController()
        profileVC.onExit = exitAction
        let libraryVC = MyBooksViewController()
        let sessionVC = SessionViewController()
        
        profileVC.tabBarItem = UITabBarItem(title: nil, image: UIImage(named: "profileSelected"), selectedImage: UIImage(named: "profileSelected"))
        profileVC.tabBarItem.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
        libraryVC.tabBarItem = UITabBarItem(title: nil, image: UIImage(named: "librarySelected"), selectedImage: UIImage(named: "librarySelected"))
        libraryVC.tabBarItem.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
        sessionVC.tabBarItem = UITabBarItem(title: nil, image: UIImage(named: "sessionSelected"), selectedImage: UIImage(named: "sessionSelected"))
        sessionVC.tabBarItem.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
        
        sessionVC.onBookAddedInSession = { bookModel in
            libraryVC.pushBook(book: bookModel)
        }
        
        libraryVC.onBooksListUpdated = { list in
            sessionVC.updateWithBook(book: list.first)
            profileVC.booksStorage = list
        }
        
        libraryVC.onTapToStartSession = { [weak self] book in
            let alert = UIAlertController(title: "Выбор книги", message: "Начать сессию с выбранной книгой?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Начать!", style: .default, handler: ({ [weak self] _ in
                sessionVC.updateWithBook(book: book)
                self?.mainTabBarController.selectedIndex = 2
            })))
            alert.addAction(UIAlertAction(title: "Отмена", style: .default, handler: nil))
            self?.present(alert, animated: true, completion: nil)
        }
        
        sessionVC.onBookSelectFromLibraryRequest = { [weak self] in
            self?.mainTabBarController.selectedIndex = 1
        }
        
        let controllers = [profileVC, libraryVC, sessionVC]
        
        mainTabBarController.viewControllers = controllers.map{ UINavigationController.init(rootViewController: $0)}
        mainTabBarController.selectedIndex = 2
        mainTabBarController.tabBar.barTintColor = UIColor(rgb: 0x2f5870)
        mainTabBarController.tabBar.tintColor = .white
        addChild(mainTabBarController)
        view.addSubview(mainTabBarController.view)
        mainTabBarController.didMove(toParent: self)
    }
    
    private func exitAction() {
        do {
            try Auth.auth().signOut()
        } catch {
            print("Exit error occured")
        }
        
        interactor?.checkLogin(onStartLoad: ({ [weak self] in
            //self?.spinner?.startAnimating()
        }), onFinishLoad: ({ [weak self] in
            //self?.spinner?.stopAnimating()
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

class AnimatedTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
    }
}

extension AnimatedTabBarController: UITabBarControllerDelegate  {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        
        guard let fromView = selectedViewController?.view, let toView = viewController.view else {
            return false
        }
        
        if fromView != toView {
            UIView.transition(from: fromView, to: toView, duration: 0.1, options: [.transitionCrossDissolve], completion: nil)
        }
        
        return true
    }
}
