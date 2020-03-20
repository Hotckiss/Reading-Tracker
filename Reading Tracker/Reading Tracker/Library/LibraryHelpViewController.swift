//
//  LibraryHelpViewController.swift
//  Reading Tracker
//
//  Created by Andrei Kirilenko on 1/21/19.
//  Copyright © 2019 Andrei Kirilenko. All rights reserved.
//

import Foundation
import UIKit
import Firebase

final class LibraryHelpViewController: UIViewController {
    private var navBar: NavigationBar?
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        let navBar = NavigationBar()
        
        navBar.configure(model: NavigationBarModel(title: "Помощь",
                                                   onBackButtonPressed: ({ [weak self] in
                                                    self?.dismiss(animated: true, completion: nil)
                                                   })))
        navBar.backgroundColor = UIColor(rgb: 0x2f5870)
        navBar.setBackButtonImage(image: UIImage(named: "close"))
        
        view.addSubview(navBar)
        navBar.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .bottom)
        self.navBar = navBar
        
        let helpLabel = UILabel(forAutoLayout: ())
        
        helpLabel.textColor = UIColor(rgb: 0x2f5870)
        helpLabel.numberOfLines = 0
        helpLabel.font = UIFont.systemFont(ofSize: 15)
        
        helpLabel.text = "Это экран всех добавленных книг. Добавлять можно вручную, а так же сделав запрос в Google books(сканировать штрихкод книги или ввести автора и название)\n" +
            "Свайп меню дает возможность удалять и редактировать книги.\n" +
            "При ручном добавлении и редактировании книг можно изменить обложку по нажатию на область картинки.\n"
        
        view.addSubview(helpLabel)
        helpLabel.autoPinEdge(toSuperviewEdge: .left, withInset: 8)
        helpLabel.autoPinEdge(toSuperviewEdge: .right, withInset: 8)
        helpLabel.autoPinEdge(.top, to: .bottom, of: navBar, withOffset: 16)
    }
}
