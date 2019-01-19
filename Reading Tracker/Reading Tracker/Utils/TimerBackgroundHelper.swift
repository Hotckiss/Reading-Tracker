//
//  TimerBackgroundHelper.swift
//  Reading Tracker
//
//  Created by Andrei Kirilenko on 1/19/19.
//  Copyright © 2019 Andrei Kirilenko. All rights reserved.
//

import Foundation
import RxSwift

public final class TimerBackgroundHelper {
    public static var timeInBackgroundObservable: Observable<Int> {
        return timeInBackgroundSubject.asObservable()
    }
    
    private static var timeInBackgroundSubject = PublishSubject<Int>()
    private static var lastTimeWhenEnteredBackground: Date?
    
    public static func enteredBackground() {
        lastTimeWhenEnteredBackground = Date()
    }
    
    public static func enteredForeground() {
        let currentTime = Date()
        if let lastTime = lastTimeWhenEnteredBackground {
            let time = Int(currentTime.timeIntervalSince1970 - lastTime.timeIntervalSince1970)
            timeInBackgroundSubject.onNext(time)
        }
    }
}
