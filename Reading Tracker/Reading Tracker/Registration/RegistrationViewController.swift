//
//  RegistrationViewController.swift
//  Reading Tracker
//
//  Created by Andrei Kirilenko on 27.09.2018.
//  Copyright © 2018 Andrei Kirilenko. All rights reserved.
//

import Foundation
import UIKit
class RegistrationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let animals: [String] = ["Имя", "Фамилия", "Пол", "Дата рождения", "Образование", "Направление образования",
                             "Место рождения", "Место проживания", "Любимые авторы/книги",
                             "Семейное положение", "Наличие детей", "Любимый формат книги"]
    var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView = UITableView(forAutoLayout: ())
        view.addSubview(tableView)
        tableView.autoPinEdgesToSuperviewEdges()
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.tableView.tableFooterView = UIView()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.animals.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:UITableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "cell") as! UITableViewCell
        cell.textLabel?.text = self.animals[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You tapped cell number \(indexPath.row).")
    }
}
