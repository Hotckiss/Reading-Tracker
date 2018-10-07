//
//  RegistrationInteractor.swift
//  Reading Tracker
//
//  Created by Andrei Kirilenko on 07.10.2018.
//  Copyright © 2018 Andrei Kirilenko. All rights reserved.
//

import Foundation
import Firebase
import RxSwift

public class RegistrationInteractor {
    private let disposeBag = DisposeBag()
    
    private var registrationSubject = PublishSubject<AuthDataResult>()
    
    var registration: Observable<AuthDataResult> {
        return registrationSubject.asObservable()
    }
    
    deinit {
        registrationSubject.onCompleted()
    }
    
    public func onRegistered(_ result: AuthDataResult) {
        registrationSubject.onNext(result)
    }
}
