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
    let mainTabBarController = AnimatedTabBarController()
    var interactor: MainInteractor?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        view.backgroundColor = .white
        
        setupSubviews()
        
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
        
        let statsVC = StatisticsViewController()
        statsVC.onExit = exitAction
        let libraryVC = MyBooksViewController()
        let sessionVC = SessionViewController()
        
        statsVC.tabBarItem = UITabBarItem(title: nil, image: UIImage(named: "statsTabBar"), selectedImage: UIImage(named: "statsTabBar"))
        statsVC.tabBarItem.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
        libraryVC.tabBarItem = UITabBarItem(title: nil, image: UIImage(named: "libraryTabBar"), selectedImage: UIImage(named: "libraryTabBar"))
        libraryVC.tabBarItem.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
        sessionVC.tabBarItem = UITabBarItem(title: nil, image: UIImage(named: "sessionTabBar"), selectedImage: UIImage(named: "sessionTabBar"))
        sessionVC.tabBarItem.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
        
        libraryVC.onBooksListUpdated = { list in
            let filtered = list.filter({ !$0.isDeleted })
            sessionVC.updateWithBook(book: filtered.first)
            statsVC.updateBooksStorage(books: list)
        }
        
        libraryVC.onTapToStartSession = { [weak self] book in
            let alert = UIAlertController(title: "Выбор книги", message: "Начать сессию с выбранной книгой?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Начать!", style: .default, handler: ({ [weak self] _ in
                sessionVC.updateWithBook(book: book)
                self?.mainTabBarController.selectedIndex = 1
            })))
            alert.addAction(UIAlertAction(title: "Отмена", style: .default, handler: nil))
            self?.present(alert, animated: true, completion: nil)
        }
        
        sessionVC.onBookSelectFromLibraryRequest = { [weak self] in
            self?.mainTabBarController.selectedIndex = 2
        }
        
        sessionVC.onBookAddedInSession = { bookModel in
            libraryVC.pushBook(book: bookModel)
        }
        
        sessionVC.onSessionUploaded = { [weak self] usm in
            statsVC.pushSession(session: usm)
            libraryVC.updateBookAfterSession(id: usm.bookId, lastPage: usm.finishPage)
            self?.mainTabBarController.selectedIndex = 0
        }
        
        let controllers = [statsVC, sessionVC, libraryVC]
        
        mainTabBarController.viewControllers = controllers.map{ UINavigationController.init(rootViewController: $0)}
        mainTabBarController.selectedIndex = 1
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
