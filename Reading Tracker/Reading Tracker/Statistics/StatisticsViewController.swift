//
//  StatisticsViewController.swift
//  Reading Tracker
//
//  Created by Andrei Kirilenko on 15.10.2018.
//  Copyright © 2018 Andrei Kirilenko. All rights reserved.
//

import Foundation
import UIKit

final class StatisticsViewController: UIViewController {
    private var navBar: NavigationBar?
    private var periodView: PeriodSelectionView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        view.backgroundColor = .white
        
        let navBar = NavigationBar()
        
        navBar.configure(model: NavigationBarModel(title: "Чтение", backButtonText: "Назад", onBackButtonPressed: ({ [weak self] in
            self?.navigationController?.popViewController(animated: true)
        })))
        navBar.backgroundColor = UIColor(rgb: 0x2f5870)
        
        view.addSubview(navBar)
        navBar.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .bottom)
        self.navBar = navBar
        
        let periodView = PeriodSelectionView(frame: .zero)
        
        periodView.update(title: "Все время")
        periodView.onTap = { [weak self] in
            print("TODO: different time intervals")
        }
        
        view.addSubview(periodView)
        periodView.autoPinEdge(.top, to: .bottom, of: navBar)
        periodView.autoPinEdge(toSuperviewEdge: .left)
        periodView.autoPinEdge(toSuperviewEdge: .right)
        self.periodView = periodView
        
        let overall = OverallStatsView(frame: .zero)
        view.addSubview(overall)
        overall.autoSetDimensions(to: SizeDependent.instance.convertSize(CGSize(width: 230, height: 230)))
        overall.autoAlignAxis(toSuperviewAxis: .vertical)
        overall.autoPinEdge(.top, to: .bottom, of: periodView, withOffset: 8)
        overall.update(booksCount: 7, minsCount: 7257, approachesCount: 213)
        
        let segmentControl = SegmentedControl(frame: .zero)
        segmentControl.layer.shadowColor = UIColor.black.cgColor
        segmentControl.layer.shadowOpacity = 0.2
        segmentControl.layer.shadowRadius = 2
        segmentControl.layer.shadowOffset = CGSize(width: 0.0, height: 3.0)
        view.addSubview(segmentControl)
        segmentControl.autoPinEdge(.top, to: .bottom, of: overall, withOffset: 16)
        segmentControl.autoPinEdge(toSuperviewEdge: .left)
        segmentControl.autoPinEdge(toSuperviewEdge: .right)
        segmentControl.autoSetDimension(.height, toSize: 42)
        segmentControl.setSegments(items: ["Записи", "По книгам", "Графики"])
        segmentControl.setSelected(index: 0)
        segmentControl.didSelectSegmentItem = { index in
            segmentControl.setSelected(index: index)
            print(index)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
    }
}
