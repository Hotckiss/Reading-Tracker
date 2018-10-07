//
//  RegistrationDraft.swift
//  Reading Tracker
//
//  Created by Andrei Kirilenko on 07.10.2018.
//  Copyright © 2018 Andrei Kirilenko. All rights reserved.
//

import Foundation

public class RegistrationDraft {
    public static let registrationDraftInstance = RegistrationDraft()
    
    private enum Consts {
        static let loginKey = "login"
        static let firstNameKey = "firstName"
        static let lastNameKey = "lastName"
        static let sexKey = "sex"
    }
    private init() {
    }
    
    public func setLogin(login: String) {
        UserDefaults.standard.set(login, forKey: Consts.loginKey)
    }
    
    public func getLogin() -> String {
        return (UserDefaults.standard.object(forKey: Consts.loginKey) as? String) ?? ""
    }
    
    public func setFirstName(firstName: String) {
        UserDefaults.standard.set(firstName, forKey: Consts.firstNameKey)
    }
    
    public func getFirstName() -> String {
        return (UserDefaults.standard.object(forKey: Consts.firstNameKey) as? String) ?? ""
    }
    
    public func setLastName(lastName: String) {
        UserDefaults.standard.set(lastName, forKey: Consts.lastNameKey)
    }
    
    public func getLastName() -> String {
        return (UserDefaults.standard.object(forKey: Consts.lastNameKey) as? String) ?? ""
    }
    
    public func setSex(sex: Bool) {
        UserDefaults.standard.set(sex, forKey: Consts.sexKey)
    }
    
    public func getSex() -> Bool {
        return UserDefaults.standard.bool(forKey: Consts.sexKey)
    }
}
