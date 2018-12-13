//
//  SessionFinishModels.swift
//  Reading Tracker
//
//  Created by Andrei Kirilenko on 11/12/2018.
//  Copyright © 2018 Andrei Kirilenko. All rights reserved.
//

import Foundation

public struct SessionFinishModel {
    var bookInfo: BookModel
    var startPage: Int
    var finishPage: Int
    var time: Int
    var startTime: Date
    var finishTime: Date
    var mood: Mood
    var readPlace: ReadPlace
    var comment: String
    
    public init(bookInfo: BookModel = BookModel(),
                startPage: Int = 1,
                finishPage: Int = 2,
                time: Int = 0,
                startTime: Date = Date(),
                finishTime: Date = Date(),
                mood: Mood = .unknown,
                readPlace: ReadPlace = .unknown,
                comment: String = "") {
        self.bookInfo = bookInfo
        self.startPage = startPage
        self.finishPage = finishPage
        self.time = time
        self.startTime = startTime
        self.finishTime = finishTime
        self.mood = mood
        self.readPlace = readPlace
        self.comment = comment
    }
}

public struct UploadSessionModel {
    var bookId: String
    var startPage: Int
    var finishPage: Int
    var time: Int
    var startTime: Date
    var mood: Mood
    var readPlace: ReadPlace
    var comment: String
    
    public init(bookId: String = "",
                startPage: Int = 1,
                finishPage: Int = 2,
                time: Int = 0,
                startTime: Date = Date(),
                mood: Mood = .unknown,
                readPlace: ReadPlace = .unknown,
                comment: String = "") {
        self.bookId = bookId
        self.startPage = startPage
        self.finishPage = finishPage
        self.time = time
        self.startTime = startTime
        self.mood = mood
        self.readPlace = readPlace
        self.comment = comment
    }
}
