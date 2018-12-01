//
//  SessionsStatisticsViewController.swift
//  Reading Tracker
//
//  Created by Andrei Kirilenko on 01/12/2018.
//  Copyright © 2018 Andrei Kirilenko. All rights reserved.
//

import Foundation
import UIKit

final class SessionsStatisticsViewController: UIViewController {
    private var spinner: SpinnerView?
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupSpinner()
        
        let placeholderTextAttributes = [
            NSAttributedString.Key.foregroundColor : UIColor(rgb: 0x2f5870).withAlphaComponent(0.5),
            NSAttributedString.Key.font : UIFont(name: "Avenir-Light", size: 20.0)!]
            as [NSAttributedString.Key : Any]
        
        let nameTextField = RTTextField(padding: .zero)
        nameTextField.attributedPlaceholder = NSAttributedString(string: "Название книги", attributes: placeholderTextAttributes)
        nameTextField.backgroundColor = .clear
        nameTextField.autocorrectionType = .no
        nameTextField.returnKeyType = .continue
        nameTextField.text = "11111"
        
        view.addSubview(nameTextField)
        nameTextField.autoAlignAxis(toSuperviewAxis: .vertical)
        nameTextField.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 124, left: 16, bottom: 0, right: 16), excludingEdge: .bottom)
    }
    
    @objc private func onAddCover() {
    }
    
    private func setupSpinner() {
        let spinner = SpinnerView(frame: .zero)
        view.addSubview(spinner)
        
        view.bringSubviewToFront(spinner)
        spinner.autoPinEdgesToSuperviewEdges()
        self.spinner = spinner
    }
}
