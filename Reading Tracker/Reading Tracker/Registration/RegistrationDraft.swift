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
        static let majorKey = "major"
        static let occupationKey = "occupation"
        static let educationKey = "education"
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
    
    public func setEducation(education: String) {
        UserDefaults.standard.set(education, forKey: Consts.educationKey)
    }
    
    public func getEducation() -> String {
        return (UserDefaults.standard.object(forKey: Consts.educationKey) as? String) ?? ""
    }
    
    public func setMajor(major: String) {
        UserDefaults.standard.set(major, forKey: Consts.majorKey)
    }
    
    public func getMajor() -> String {
        return (UserDefaults.standard.object(forKey: Consts.majorKey) as? String) ?? ""
    }
    
    public func setOccupation(occupation: String) {
        UserDefaults.standard.set(occupation, forKey: Consts.occupationKey)
    }
    
    public func getOccupation() -> String {
        return (UserDefaults.standard.object(forKey: Consts.occupationKey) as? String) ?? ""
    }
}
