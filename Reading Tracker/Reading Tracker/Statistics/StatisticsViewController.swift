//
//  StatisticsViewController.swift
//  Reading Tracker
//
//  Created by Andrei Kirilenko on 15.10.2018.
//  Copyright © 2018 Andrei Kirilenko. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import ActionSheetPicker_3_0

public enum StatsInterval {
    case allTime
    case lastYear
    case lastMonth
    case lastWeek
    case lastDay
    
    init(int: Int) {
        switch int {
        case 1:
            self = .lastYear
        case 2:
            self = .lastMonth
        case 3:
            self = .lastWeek
        case 4:
            self = .lastDay
        default:
            self = .allTime
        }
    }
    func getIndex() -> Int {
        switch self {
        case .allTime:
            return 0
        case .lastYear:
            return 1
        case .lastMonth:
            return 2
        case .lastWeek:
            return 3
        case .lastDay:
            return 4
        }
    }
    
    func getString() -> String {
        switch self {
        case .allTime:
            return "Все время"
        case .lastYear:
            return "Год"
        case .lastMonth:
            return "Месяц"
        case .lastWeek:
            return "Неделя"
        case .lastDay:
            return "День"
        }
    }
    
    public static func getAllStrings() -> [String] {
        return StatsInterval.all.map {
            $0.getString()
        }
    }
    
    public static let all: [StatsInterval] = [.allTime, .lastYear, .lastMonth, .lastWeek, .lastDay]
}

final class StatisticsViewController: UIViewController, UIScrollViewDelegate {
    private var navBar: NavigationBar?
    private var periodView: PeriodSelectionView?
    private var contentView: UIScrollView!
    private var segmentControl: SegmentedControl!
    private var segmentControlTopInset: NSLayoutConstraint?
    private var childsVC: [UIViewController] = [SessionsStatisticsViewController(),
                                               BooksStatisticsViewController(),
                                               PlotsStatisticsViewController()]
    private var currentIndex: Int = 0
    private var container: UIView!
    private var handler: AuthStateDidChangeListenerHandle?
    private var sessions: [UploadSessionModel] = []
    private var booksMap: [String : BookModel] = [:]
    private var overallView: OverallStatsView?
    private var cuttentInterval: StatsInterval = .allTime
    
    convenience init(books: [BookModel]) {
        self.init(nibName: nil, bundle: nil)
        
        for book in books {
            booksMap[book.id] = book
        }
    }
    
    deinit {
        if let handler = handler {
            Auth.auth().removeStateDidChangeListener(handler)
        }
    }
    
    func update() {
        var secs = 0
        for session in sessions {
            secs += session.time
        }
        overallView?.update(booksCount: booksMap.count, minsCount: secs / 60, approachesCount: sessions.count)
        
        if let vc = childsVC[currentIndex] as? SessionsStatisticsViewController {
            vc.update(sessions: sessions, booksMap: booksMap, interval: cuttentInterval)
        }
        
        if let vc = childsVC[currentIndex] as? BooksStatisticsViewController {
            vc.update(sessions: sessions, booksMap: booksMap, interval: cuttentInterval)
        }
        
        if let vc = childsVC[currentIndex] as? PlotsStatisticsViewController {
            vc.update(sessions: sessions, booksMap: booksMap, interval: cuttentInterval)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
            let picker = ActionSheetMultipleStringPicker(title: "Период статистики", rows: [StatsInterval.getAllStrings()],
                                                         initialSelection: [self?.cuttentInterval.getIndex() ?? 0], doneBlock: { [weak self]
                                                            picker, values, indexes in
                                                            if let values = values,
                                                                let optionIndex = values.first as? Int {
                                                                let newInterval = StatsInterval(int: optionIndex)
                                                                self?.cuttentInterval = newInterval
                                                                periodView.update(title: newInterval.getString())
                                                                return
                                                            }
                                                            return
                }, cancel: { ActionMultipleStringCancelBlock in return }, origin: periodView)
            picker?.setTextColor(UIColor(rgb: 0x2f5870))
            
            let textAttributes = [
                NSAttributedString.Key.foregroundColor : UIColor(rgb: 0x2f5870),
                NSAttributedString.Key.font : UIFont(name: "Avenir-Medium", size: 17.0)!]
                as [NSAttributedString.Key : Any]
            
            let finishButton = UIButton(forAutoLayout: ())
            finishButton.setAttributedTitle(NSAttributedString(string: "Готово", attributes: textAttributes), for: [])
            picker?.setDoneButton(UIBarButtonItem(customView: finishButton))
            
            let closeButton = UIButton(forAutoLayout: ())
            closeButton.setAttributedTitle(NSAttributedString(string: "Закрыть", attributes: textAttributes), for: [])
            picker?.setCancelButton(UIBarButtonItem(customView: closeButton))
            picker?.show()
            print("TODO: different time intervals")
        }
        
        view.addSubview(periodView)
        periodView.autoPinEdge(.top, to: .bottom, of: navBar)
        periodView.autoPinEdge(toSuperviewEdge: .left)
        periodView.autoPinEdge(toSuperviewEdge: .right)
        self.periodView = periodView
        
        contentView = UIScrollView(frame: .zero)
        contentView.isScrollEnabled = true
        contentView.alwaysBounceVertical = true
        contentView.delegate = self
        contentView.showsVerticalScrollIndicator = false
        view.addSubview(contentView)
        contentView.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .top)
        contentView.autoPinEdge(.top, to: .bottom, of: periodView)
        
        let overall = OverallStatsView(frame: .zero)
        contentView.addSubview(overall)
        overall.autoSetDimensions(to: SizeDependent.instance.convertSize(CGSize(width: 230, height: 230)))
        overall.autoAlignAxis(toSuperviewAxis: .vertical)
        overall.autoPinEdge(toSuperviewEdge: .top, withInset: 8)
        overall.update(booksCount: 0, minsCount: 0, approachesCount: 0)
        self.overallView = overall
        
        let segmentControl = SegmentedControl(frame: .zero)
        segmentControl.layer.shadowColor = UIColor.black.cgColor
        segmentControl.layer.shadowOpacity = 0.2
        segmentControl.layer.shadowRadius = 2
        segmentControl.layer.shadowOffset = CGSize(width: 0.0, height: 3.0)
        view.addSubview(segmentControl)
        segmentControlTopInset = segmentControl.autoPinEdge(.top, to: .bottom, of: periodView, withOffset: SizeDependent.instance.convertSize(CGSize(width: 230, height: 230)).height + CGFloat(24))
        segmentControl.autoPinEdge(toSuperviewEdge: .left)
        segmentControl.autoPinEdge(toSuperviewEdge: .right)
        segmentControl.autoSetDimension(.height, toSize: 42)
        segmentControl.setSegments(items: ["Записи", "По книгам", "Графики"])
        segmentControl.setSelected(index: 0)
        view.bringSubviewToFront(segmentControl)
        self.segmentControl = segmentControl
        segmentControl.didSelectSegmentItem = { [weak self] index in
            segmentControl.setSelected(index: index)
            self?.setController(index: index)
        }
        
        let container = UIView(frame: .zero)
        contentView.addSubview(container)
        container.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .top)
        container.autoMatch(.width, to: .width, of: contentView)
        container.autoPinEdge(.top, to: .bottom, of: overall, withOffset: 60)
        container.autoPinEdge(toSuperviewEdge: .bottom)
        self.container = container
        
        setController(index: 0)
        
        handler = Auth.auth().addStateDidChangeListener { [weak self] (auth, user) in
            if user != nil {
                FirestoreManager.DBManager.getAllSessions(completion: { sessions in
                    self?.sessions = sessions
                    self?.update()
                },
                                                          onError: ({ [weak self] in
                                                            //self?.spinner?.hide()
                                                          }))
            } else {
                self?.sessions = []
            }
        }
        update()
    }
    
    private func setController(index: Int) {
        if let currentChild = children.first {
            currentChild.willMove(toParent: nil)
            currentChild.view.removeFromSuperview()
            currentChild.removeFromParent()
            currentChild.setEditing(false, animated: false)
        }
        
        guard index < childsVC.count else {
            return
        }
        currentIndex = index
        let viewController = childsVC[index]
        addChild(viewController)
        container.addSubview(viewController.view)
        if #available(iOS 11, *) {
        } else {
            viewController.viewWillAppear(false)
        }
        
        if let vc = viewController as? SessionsStatisticsViewController {
            vc.update(sessions: sessions, booksMap: booksMap, interval: cuttentInterval)
        }
        
        if let vc = viewController as? BooksStatisticsViewController {
            vc.update(sessions: sessions, booksMap: booksMap, interval: cuttentInterval)
        }
        
        if let vc = viewController as? PlotsStatisticsViewController {
            vc.update(sessions: sessions, booksMap: booksMap, interval: cuttentInterval)
        }
        
        viewController.view.autoPinEdgesToSuperviewEdges()
        viewController.didMove(toParent: self)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        segmentControlTopInset?.constant = max(SizeDependent.instance.convertSize(CGSize(width: 230, height: 230)).height + CGFloat(24) - scrollView.bounds.origin.y, 0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
}
