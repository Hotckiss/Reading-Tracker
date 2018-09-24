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
    private var isAuthorized: Bool = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Reading Tracker"
        view.backgroundColor = .white
        
        
        let label = UILabel(frame: .zero)
        label.textColor = .blue
        label.text = "testLabel"
        view.addSubview(label)
        label.autoCenterInSuperview()
    }

    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = false
        if !isAuthorized {
            let vc = AuthorizationViewController()
            
            navigationController?.pushViewController(vc, animated: false)
            isAuthorized = true
        }
    }
}

