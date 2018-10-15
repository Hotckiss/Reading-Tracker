//
//  UserModel.swift
//  Reading Tracker
//
//  Created by Andrei Kirilenko on 05.10.2018.
//  Copyright © 2018 Andrei Kirilenko. All rights reserved.
//

import Foundation

public struct UserModel {
    public var firstName: String
    public var lastName: String
    public var birthDate: String
    public var gender: Bool
    public var degree: String
    public var major: String
    public var occupation: String
    public var favoriteBooks: String
    public var favoriteAuthors: String
    public var favoriteFormat: String
    
    public init(firstName: String,
                lastName: String,
                birthDate: String,
                gender: Bool,
                degree: String,
                major: String,
                occupation: String,
                favoriteBooks: String,
                favoriteAuthors: String,
                favoriteFormat: String) {
        self.firstName = firstName
        self.lastName = lastName
        self.birthDate = birthDate
        self.gender = gender
        self.degree = degree
        self.major = major
        self.occupation = occupation
        self.favoriteBooks = favoriteBooks
        self.favoriteAuthors = favoriteAuthors
        self.favoriteFormat = favoriteFormat
    }
    
    public init() {
        self.init(firstName: "",
                  lastName: "",
                  birthDate: "",
                  gender: false,
                  degree: "",
                  major: "",
                  occupation: "",
                  favoriteBooks: "",
                  favoriteAuthors: "",
                  favoriteFormat: "")
    }
}
