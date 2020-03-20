//
//  OnLiginStuff.swift
//  Reading Tracker
//
//  Created by Andrei Kirilenko on 04/11/2018.
//  Copyright © 2018 Andrei Kirilenko. All rights reserved.
//

import Foundation
import Firebase
public final class OnLiginStuff {
    public static func tryLogin(credential: AuthCredential, completion: ((AuthDataResult) -> Void)?) {
        Auth.auth().signInAndRetrieveData(with: credential) { (authResult, error) in
            if let error = error {
                print("Error in auth: \(error.localizedDescription)")
                return
            }
            if let authResult = authResult {
                completion?(authResult)
            } else {
                print("Error in auth: authResult is nil")
            }
        }
    }
}
