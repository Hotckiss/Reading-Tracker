//
//  ProfileViewController.swift
//  Reading Tracker
//
//  Created by Andrei Kirilenko on 05/11/2018.
//  Copyright © 2018 Andrei Kirilenko. All rights reserved.
//

import Foundation
import UIKit

public struct ProfileOption {
    public let title: String
    public let subtitle: String
    
    public init(title: String,
                subtitle: String = "") {
        self.title = title
        self.subtitle = subtitle
    }
}

final class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    private var spinner: UIActivityIndicatorView?
    private var profileOptions: [ProfileOption] = [ProfileOption(title: "Анкета участника исследования", subtitle: "Заполняя анкету, вы учавствуете в научном исследовании читателей и их интересов"),
                                                   ProfileOption(title: "Настройки"),
                                                   ProfileOption(title: "Выход")]
    private var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        view.backgroundColor = .white
        setupNavigationBar()
        setupSpinner()
    }
    
    private func setupNavigationBar() {
        let navBar = NavigationBar()
        
        navBar.configure(model: NavigationBarModel(title: "Профиль читателя"))
        navBar.backgroundColor = UIColor(rgb: 0xedaf97)
        
        view.addSubview(navBar)
        navBar.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .bottom)
        
        tableView = UITableView(forAutoLayout: ())
        view.addSubview(tableView)
        tableView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: UIApplication.shared.statusBarFrame.height + 4 + 32 + 4, left: 0, bottom: 0, right: 0))
        tableView.register(ProfileCell.self, forCellReuseIdentifier: "profileCell")
        tableView.tableFooterView = UIView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .white
        tableView.separatorInset = .zero
        tableView.separatorColor = UIColor(rgb: 0x2f5870)
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return profileOptions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: ProfileCell = self.tableView.dequeueReusableCell(withIdentifier: "profileCell") as! ProfileCell
        cell.configure(model: profileOptions[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
    
    private class ProfileCell: UITableViewCell {
        private var model: ProfileOption = ProfileOption(title: "")
        private var titleLabel: UILabel?
        private var subtitleLabel: UILabel?
        
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            backgroundColor = .white
            selectionStyle = .none
            setupSubviews()
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private func setupSubviews() {
            let titleLabel = UILabel(forAutoLayout: ())
            
            let titleTextAttributes = [
                NSAttributedString.Key.foregroundColor : UIColor(rgb: 0x2f5870),
                NSAttributedString.Key.font : UIFont(name: "Avenir-Medium", size: 20.0)!]
                as [NSAttributedString.Key : Any]
            
            titleLabel.attributedText = NSAttributedString(string: model.title, attributes: titleTextAttributes)
            titleLabel.numberOfLines = 0
            
            addSubview(titleLabel)
            
            titleLabel.autoPinEdge(toSuperviewEdge: .left, withInset: 16)
            titleLabel.autoPinEdge(toSuperviewEdge: .right, withInset: 16)
            titleLabel.autoPinEdge(toSuperviewEdge: .top, withInset: 30)
            
            let subtitleLabel = UILabel(forAutoLayout: ())
            
            let subtitleTextAttributes = [
                NSAttributedString.Key.foregroundColor : UIColor(rgb: 0x2f5870).withAlphaComponent(0.5),
                NSAttributedString.Key.font : UIFont(name: "Avenir-Light", size: 16.0)!]
                as [NSAttributedString.Key : Any]
            
            subtitleLabel.attributedText = NSAttributedString(string: model.subtitle, attributes: subtitleTextAttributes)
            subtitleLabel.numberOfLines = 0
            addSubview(subtitleLabel)
            
            subtitleLabel.autoPinEdge(toSuperviewEdge: .left, withInset: 16)
            subtitleLabel.autoPinEdge(toSuperviewEdge: .right, withInset: 16)
            subtitleLabel.autoPinEdge(toSuperviewEdge: .bottom, withInset: 30)
            subtitleLabel.autoPinEdge(.top, to: .bottom, of: titleLabel, withOffset: 5)
            
            self.titleLabel = titleLabel
            self.subtitleLabel = subtitleLabel
        }
        
        func configure(model: ProfileOption) {
            self.model = model
            
            let titleTextAttributes = [
                NSAttributedString.Key.foregroundColor : UIColor(rgb: 0x2f5870),
                NSAttributedString.Key.font : UIFont(name: "Avenir-Medium", size: 20.0)!]
                as [NSAttributedString.Key : Any]
            
            let subtitleTextAttributes = [
                NSAttributedString.Key.foregroundColor : UIColor(rgb: 0x2f5870).withAlphaComponent(0.5),
                NSAttributedString.Key.font : UIFont(name: "Avenir-Light", size: 16.0)!]
                as [NSAttributedString.Key : Any]
            
            titleLabel?.attributedText = NSAttributedString(string: model.title, attributes: titleTextAttributes)
            subtitleLabel?.attributedText = NSAttributedString(string: model.subtitle, attributes: subtitleTextAttributes)
        }
    }
}

