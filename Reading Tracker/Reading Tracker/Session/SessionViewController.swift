//
//  SessionViewController.swift
//  Reading Tracker
//
//  Created by Andrei Kirilenko on 15.10.2018.
//  Copyright © 2018 Andrei Kirilenko. All rights reserved.
//

import Foundation
import UIKit

final class SessionViewController: UIViewController {
    private var spinner: UIActivityIndicatorView?
    private var sessionButton: SessionTimerButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        view.backgroundColor = .white
        setupNavigationBar()
        setupSpinner()
        
        let s = SessionTimerButton(frame: .zero)
        view.addSubview(s)
        
        s.autoPinEdge(toSuperviewEdge: .bottom, withInset: 100)
        s.autoAlignAxis(toSuperviewAxis: .vertical)
        s.autoSetDimensions(to: CGSize(width: 230, height: 230))
        s.addTarget(self, action: #selector(onSessionButtonTap), for: .touchUpInside)
        s.buttonState = .start
        sessionButton = s
    }
    
    @objc private func onSessionButtonTap() {
        guard let sessionButton = sessionButton else {
            return
        }
        
        if sessionButton.buttonState == .play {
            sessionButton.buttonState = .pause
        } else {
            sessionButton.buttonState = .play
        }
    }
    private func setupNavigationBar() {
        let navBar = NavigationBar()
        
        navBar.configure(model: NavigationBarModel(title: "Новая запись о чтении",
                                                   backButtonText: "<-",
                                                   frontButtonText: "V",
                                                   onBackButtonPressed: ({
                                                   }),
                                                   onFrontButtonPressed: ({
                                                   })))
        navBar.backgroundColor = UIColor(rgb: 0xedaf97)
        
        view.addSubview(navBar)
        navBar.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .bottom)
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
