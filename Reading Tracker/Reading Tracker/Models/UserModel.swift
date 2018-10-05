//
//  UserModel.swift
//  Reading Tracker
//
//  Created by Andrei Kirilenko on 05.10.2018.
//  Copyright © 2018 Andrei Kirilenko. All rights reserved.
//

import Foundation

public struct UserModel {
    public var name: String
    public var birthDate: String
    public var gender: String
    public var degree: String
    public var major: String
    public var occupation: String
    public var favouriteBooks: String
    public var favouriteFormat: String
    
    public init(name: String,
                birthDate: String,
                gender: String,
                degree: String,
                major: String,
                occupation: String,
                favouriteBooks: String,
                favouriteFormat: String) {
        self.name = name
        self.birthDate = birthDate
        self.gender = gender
        self.degree = degree
        self.major = major
        self.occupation = occupation
        self.favouriteBooks = favouriteBooks
        self.favouriteFormat = favouriteFormat
    }
}
