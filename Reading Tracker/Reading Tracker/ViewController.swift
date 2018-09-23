//
//  ViewController.swift
//  Reading Tracker
//
//  Created by Andrei Kirilenko on 23.09.2018.
//  Copyright © 2018 Andrei Kirilenko. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Reading Tracker"
        view.backgroundColor = .white
        
        let label = UILabel(frame: CGRect(x: 50, y: 50, width: 100, height: 100))
        label.textColor = .blue
        label.text = "testLabel"
        view.addSubview(label)
    }


}

