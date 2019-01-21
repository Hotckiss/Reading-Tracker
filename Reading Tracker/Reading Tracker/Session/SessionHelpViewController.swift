//
//  SessionHelpViewController.swift
//  Reading Tracker
//
//  Created by Andrei Kirilenko on 1/21/19.
//  Copyright © 2019 Andrei Kirilenko. All rights reserved.
//

import Foundation
import UIKit
import Firebase

final class SessionHelpViewController: UIViewController {
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
        
        helpLabel.text = "Это экран добавления сессии. Книга по умолчанию стоит первая из библиотеки, если такой нет, ее можно добавить.\n" +
            "При нажатии на кнопку старта, запускается таймер, который можно при желании поставить на паузу.\n" +
            "Можно также ввести все данный вручную, для этого надо выбрать дату(по нажатию на дату), а также время начала и конца чтения(по нажатию на соответствующие часы)\n" +
            "После завершения ввода времени необходимо ввести начальную и конечную страницы(начальная не больше конечной). Начальная страница подставляется изначально как последняя прочитанная из предыдущих сессий, а последняя -- на основе скорости чтения данной книги раньше\n" +
        "Опционально можно ввести заметку и свои эмоции во время чтения"
        
        view.addSubview(helpLabel)
        helpLabel.autoPinEdge(toSuperviewEdge: .left, withInset: 8)
        helpLabel.autoPinEdge(toSuperviewEdge: .right, withInset: 8)
        helpLabel.autoPinEdge(.top, to: .bottom, of: navBar, withOffset: 16)
    }
}
