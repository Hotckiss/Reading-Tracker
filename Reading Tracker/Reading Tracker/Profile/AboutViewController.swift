//
//  AboutViewController.swift
//  Reading Tracker
//
//  Created by Andrei Kirilenko on 1/19/19.
//  Copyright © 2019 Andrei Kirilenko. All rights reserved.
//

import Foundation
import UIKit
import Firebase

final class AboutViewController: UIViewController {
    private var spinner: SpinnerView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        var bottomSpace: CGFloat = 49
        if #available(iOS 11.0, *) {
            bottomSpace += UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
        }
        let navBar = NavigationBar()
        
        navBar.configure(model: NavigationBarModel(title: "О приложении",
                                                   onBackButtonPressed: ({ [weak self] in
                                                    self?.navigationController?.popViewController(animated: true)
                                                   })))
        navBar.backgroundColor = UIColor(rgb: 0x2f5870)
        navBar.setBackButtonImage(image: UIImage(named: "back"))
        view.addSubview(navBar)
        navBar.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .bottom)
        
        let aboutLabel = UILabel(forAutoLayout: ())
        aboutLabel.textAlignment = .center
        aboutLabel.font = UIFont.systemFont(ofSize: 17)
        aboutLabel.textColor = UIColor(rgb: 0x2f5870).withAlphaComponent(0.7)
        aboutLabel.numberOfLines = 0
        let text = "Дневник читетеля\nAndrey Kirilenko\nSaint-Petersburg, HSE, 2019"
        aboutLabel.text = text
        
        view.addSubview(aboutLabel)
        aboutLabel.autoPinEdge(toSuperviewEdge: .bottom, withInset: bottomSpace + 16)
        aboutLabel.autoAlignAxis(toSuperviewAxis: .vertical)
        
        
        let descriptionLabel = UILabel(forAutoLayout: ())
        descriptionLabel.textAlignment = .center
        descriptionLabel.font = UIFont.systemFont(ofSize: 19, weight: .medium)
        descriptionLabel.textColor = UIColor(rgb: 0x2f5870)
        descriptionLabel.numberOfLines = 0
        let descriptionText = "Ссылка на анкету\nучастника эксперимента"
        descriptionLabel.text = descriptionText
        
        view.addSubview(descriptionLabel)
        descriptionLabel.autoPinEdge(.top, to: .bottom, of: navBar, withOffset: 16)
        descriptionLabel.autoAlignAxis(toSuperviewAxis: .vertical)
        
        let linkTextAttributes = [
            NSAttributedString.Key.foregroundColor : UIColor(rgb: 0x0000ff),
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: 17)]
            as [NSAttributedString.Key : Any]
        
        let linkLabel = UILabel(forAutoLayout: ())
        linkLabel.numberOfLines = 0
        let attrText = NSMutableAttributedString(string: "link", attributes: linkTextAttributes)
        attrText.addAttribute(.underlineStyle, value: 1, range: NSRange(location: 0, length: attrText.length))
        linkLabel.attributedText = attrText
        
        view.addSubview(linkLabel)
        linkLabel.autoPinEdge(.top, to: .bottom, of: descriptionLabel, withOffset: 16)
        linkLabel.autoPinEdge(toSuperviewEdge: .left, withInset: 16)
        linkLabel.autoPinEdge(toSuperviewEdge: .right, withInset: 16)
        
        setupSpinner()
    }
    
    private func setupSpinner() {
        let spinner = SpinnerView(frame: .zero)
        view.addSubview(spinner)
        
        view.bringSubviewToFront(spinner)
        spinner.autoPinEdgesToSuperviewEdges()
        self.spinner = spinner
    }
}
