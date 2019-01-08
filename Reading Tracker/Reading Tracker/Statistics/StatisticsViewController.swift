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
    
    func getSeconds() -> Int {
        switch self {
        case .allTime:
            return Int.max
        case .lastYear:
            return 365 * 24 * 60 * 60
        case .lastMonth:
            return 30 * 24 * 60 * 60
        case .lastWeek:
            return 7 * 24 * 60 * 60
        case .lastDay:
            return 24 * 60 * 60
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
    var onExit: (() -> Void)?
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
    private var currentInterval: StatsInterval = .allTime
    
    convenience init() {
        self.init(nibName: nil, bundle: nil)
        for subViewController in childsVC {
            if let vc = subViewController as? SessionsStatisticsViewController {
                vc.onRequestReload = { [weak self] session in
                    guard let strongSelf = self else {
                        return
                    }
                    
                    for i in 0..<strongSelf.sessions.count {
                        if strongSelf.sessions[i].sessionId == session.sessionId {
                            strongSelf.sessions[i] = session
                            strongSelf.update()
                            break
                        }
                    }
                }
            }
        }
    }
    
    func updateBooksStorage(books: [BookModel]) {
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
        let (filteredArr, booksCount) = filteredSessions()
        var secs = 0
        for session in filteredArr {
            secs += session.time
        }
        overallView?.update(booksCount: booksCount, minsCount: secs / 60, approachesCount: filteredArr.count)
        for subViewController in childsVC {
            if let vc = subViewController as? SessionsStatisticsViewController {
                vc.update(sessions: filteredArr, booksMap: booksMap, interval: currentInterval)
            }
            
            if let vc = subViewController as? BooksStatisticsViewController {
                vc.update(sessions: filteredArr, booksMap: booksMap, interval: currentInterval)
            }
            
            if let vc = subViewController as? PlotsStatisticsViewController {
                vc.update(sessions: filteredArr, booksMap: booksMap, interval: currentInterval)
            }
        }
    }
    
    func filteredSessions() -> ([UploadSessionModel], Int) {
        guard currentInterval != .allTime else {
            return (sessions, booksMap.count)
        }
        
        var booksCounter: [String: Bool] = [:]
        var res: [UploadSessionModel] = []
        let currentDate = Date()
        for session in sessions {
            let calendar = Calendar.current
            if let date = calendar.date(byAdding: .second, value: currentInterval.getSeconds() , to: session.startTime),
               date > currentDate {
                res.append(session)
                booksCounter[session.bookId] = true
            }
        }
        
        return (res, booksCounter.count)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        view.backgroundColor = .white
        let navBar = NavigationBar()
        
        navBar.configure(model: NavigationBarModel(title: "Статистика", onFrontButtonPressed: ({ [weak self] in
            let profileVC = ProfileViewController()
            profileVC.onExit = self?.onExit
            self?.navigationController?.pushViewController(profileVC, animated: true)
        })))
        navBar.backgroundColor = UIColor(rgb: 0x2f5870)
        navBar.setFrontButtonImage(image: UIImage(named: "profile"))
        
        view.addSubview(navBar)
        navBar.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .bottom)
        self.navBar = navBar
        
        let periodView = PeriodSelectionView(frame: .zero)
        
        periodView.update(title: "Все время")
        periodView.onTap = { [weak self] in
            let picker = ActionSheetMultipleStringPicker(title: "Период статистики", rows: [StatsInterval.getAllStrings()],
                                                         initialSelection: [self?.currentInterval.getIndex() ?? 0], doneBlock: { [weak self]
                                                            picker, values, indexes in
                                                            if let values = values,
                                                                let optionIndex = values.first as? Int {
                                                                let newInterval = StatsInterval(int: optionIndex)
                                                                self?.currentInterval = newInterval
                                                                periodView.update(title: newInterval.getString())
                                                                self?.update()
                                                                return
                                                            }
                                                            return
                }, cancel: { ActionMultipleStringCancelBlock in return }, origin: periodView)
            picker?.setTextColor(UIColor(rgb: 0x2f5870))
            
            let textAttributes = [
                NSAttributedString.Key.foregroundColor : UIColor(rgb: 0x2f5870),
                NSAttributedString.Key.font : UIFont.systemFont(ofSize: 17, weight: .medium)]
                as [NSAttributedString.Key : Any]
            
            let finishButton = UIButton(frame: CGRect(x: 0, y: 0, width: 70, height: 35))
            finishButton.setAttributedTitle(NSAttributedString(string: "Готово", attributes: textAttributes), for: [])
            picker?.setDoneButton(UIBarButtonItem(customView: finishButton))
            
            let closeButton = UIButton(frame: CGRect(x: 0, y: 0, width: 70, height: 35))
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
        
        var bottomSpace: CGFloat = 49
        if #available(iOS 11.0, *) {
            bottomSpace += UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
        }
        contentView = UIScrollView(frame: .zero)
        contentView.isScrollEnabled = true
        contentView.alwaysBounceVertical = true
        contentView.delegate = self
        contentView.showsVerticalScrollIndicator = false
        view.addSubview(contentView)
        contentView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 0, left: 0, bottom: bottomSpace, right: 0), excludingEdge: .top)
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
    
    func pushSession(session: UploadSessionModel) {
        sessions.append(session)
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
            vc.update(sessions: filteredSessions().0, booksMap: booksMap, interval: currentInterval)
        }
        
        if let vc = viewController as? BooksStatisticsViewController {
            vc.update(sessions: filteredSessions().0, booksMap: booksMap, interval: currentInterval)
        }
        
        if let vc = viewController as? PlotsStatisticsViewController {
            vc.update(sessions: filteredSessions().0, booksMap: booksMap, interval: currentInterval)
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
