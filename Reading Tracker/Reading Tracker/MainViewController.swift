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

class MainViewController: UIViewController {
    private let disposeBag = DisposeBag()
    
    private var label: UILabel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Reading Tracker"
        view.backgroundColor = .white
        
        
        let label = UILabel(frame: .zero)
        label.textColor = .blue
        label.text = "testLabel"
        view.addSubview(label)
        label.autoCenterInSuperview()
        self.label = label
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let currentUser = Auth.auth().currentUser
        if currentUser == nil {
            let vc = AuthorizationViewController()
            let interactor = AuthorizationInteractor()
            vc.interactor = interactor
            interactor.viewController = vc
            
            interactor.authorization.subscribe(onNext: ({ [weak self] user in
                self?.label?.text = user.user.email ?? "Username login"
                self?.navigationController?.popViewController(animated: true)
            })).disposed(by: disposeBag)
            
            navigationController?.pushViewController(vc, animated: false)
        } else {
            label?.text = currentUser?.email ?? ""
        }
    }
}

