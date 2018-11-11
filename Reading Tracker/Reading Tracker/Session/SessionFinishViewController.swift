//
//  SessionFinishViewController.swift
//  Reading Tracker
//
//  Created by Andrei Kirilenko on 11/11/2018.
//  Copyright © 2018 Andrei Kirilenko. All rights reserved.
//

import Foundation
import UIKit

public struct SessionFinishModel {
    var bookInfo: BookModel
    var bookType: BookType
    var startPage: Int
    var finishPage: Int
    var time: Int
    
    public init(bookInfo: BookModel,
                bookType: BookType,
                startPage: Int,
                finishPage: Int,
                time: Int) {
        self.bookInfo = bookInfo
        self.bookType = bookType
        self.startPage = startPage
        self.finishPage = finishPage
        self.time = time
    }
}
