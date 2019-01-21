//
//  StatisticsHelpViewController.swift
//  Reading Tracker
//
//  Created by Andrei Kirilenko on 1/21/19.
//  Copyright © 2019 Andrei Kirilenko. All rights reserved.
//

import Foundation
import UIKit
import Firebase

final class StatisticsHelpViewController: UIViewController {
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
        
        helpLabel.text = "В статистике вы можете найти всю информацию о ваших сессиях чтения.\n" +
        "Для выбора периода статистики нажмите на троеточие справа от временного промежутка\n" +
        "Во вкладке Записи расположен весь список сессий за период, по нажатию на сессию будет выведена подробная информация о ней, свайп справа налево даст возможность удалить сессию\n" +
        "Во вкладке Книги статистика сгруппирована по книгам, по нажатию на книгу будет выведена подробная информация с прогрессом\n" +
        "Во вкладке Графики представлена сводка основных показателей по выбранному периоду, а также распределение сессий чтения по времени суток"
        
        view.addSubview(helpLabel)
        helpLabel.autoPinEdge(toSuperviewEdge: .left, withInset: 8)
        helpLabel.autoPinEdge(toSuperviewEdge: .right, withInset: 8)
        helpLabel.autoPinEdge(.top, to: .bottom, of: navBar, withOffset: 16)
    }
}
