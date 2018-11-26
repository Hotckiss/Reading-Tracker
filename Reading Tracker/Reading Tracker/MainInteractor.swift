//
//  MainInteractor.swift
//  Reading Tracker
//
//  Created by Andrei Kirilenko on 11.10.2018.
//  Copyright © 2018 Andrei Kirilenko. All rights reserved.
//

import Foundation
import Firebase
import FirebaseFirestore
import RxSwift

final class MainInteractor {
    private let disposeBag = DisposeBag()
    
    var viewController: MainViewController?
    
    var userData: UserModel?
    
    public func checkLogin(onStartLoad: (() -> Void)?, onFinishLoad: (() -> Void)?) {
        let currentUser = Auth.auth().currentUser
        if currentUser == nil {
            let vc = AuthorizationViewController()
            let interactor = AuthorizationInteractor()
            vc.interactor = interactor
            interactor.viewController = vc
            
            interactor.authorization.subscribe(onNext: ({ user in
                onStartLoad?()
                //self.loadUserData(onComplete: onFinishLoad)
                
                self.viewController?.navigationController?.popViewController(animated: true)
            })).disposed(by: disposeBag)
            
            viewController?.navigationController?.pushViewController(vc, animated: false)
        } else {
            onStartLoad?()
            //loadUserData(onComplete: onFinishLoad)
        }
    }
    
    public func loadUserData(onComplete: (() -> Void)?) {
        FirestoreManager.DBManager.loadUserProfile(onError: ({
            //nothing to do
        })).subscribe(onNext: ({ [weak self] user in
            self?.userData = user
            onComplete?()
        })).disposed(by: disposeBag)
    }
}
