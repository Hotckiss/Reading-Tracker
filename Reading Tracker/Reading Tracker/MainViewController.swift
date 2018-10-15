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
    private var label: UILabel?
    private var spinner: UIActivityIndicatorView?
    
    var interactor: MainInteractor?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        view.backgroundColor = .white
        setupSpinner()
        
        let label = UILabel(frame: .zero)
        label.textColor = .blue
        label.text = "testLabel"
        view.addSubview(label)
        label.autoCenterInSuperview()
        self.label = label
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
        interactor?.checkLogin(onStartLoad: ({ [weak self] in
            self?.spinner?.startAnimating()
        }), onFinishLoad: ({ [weak self] in
            self?.spinner?.stopAnimating()
        }))
    }
}

