//
//  AuthorizationInteractor.swift
//  Reading Tracker
//
//  Created by Andrei Kirilenko on 24.09.2018.
//  Copyright © 2018 Andrei Kirilenko. All rights reserved.
//

import UIKit
import RxSwift
import Firebase

class AuthorizationInteractor {
    private let disposeBag = DisposeBag()
    
    var viewController: AuthorizationViewController?
    
    private var authorizationSubject = PublishSubject<AuthDataResult>()
    
    var authorization: Observable<AuthDataResult> {
        return authorizationSubject.asObservable()
    }
    
    deinit {
        authorizationSubject.onCompleted()
    }
    
    func loginButtonTapped(login: String, password: String, onCompleted: (() -> Void)?) {
        Auth.auth().signIn(withEmail: login, password: password) { [weak self] (rawUser, rawError) in
            onCompleted?()
            if let error = rawError {
                self?.viewController?.alertError(description: error.localizedDescription)
            } else if let user = rawUser {
                self?.authorizationSubject.onNext(user)
            }
        }
    }
    
    func onLogin(result: AuthDataResult) {
        authorizationSubject.onNext(result)
    }
}
