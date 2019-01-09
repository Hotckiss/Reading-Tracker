//
//  BooksModels.swift
//  Reading Tracker
//
//  Created by Andrei Kirilenko on 07/01/2019.
//  Copyright © 2019 Andrei Kirilenko. All rights reserved.
//

import Foundation
import UIKit

public enum BookType: String {
    case paper = "paper"
    case smartphone = "smartphone"
    case tab = "tablet"
    case ebook = "ebook"
    case unknown = "unknown"
    
    public static func generate(raw: String) -> BookType {
        switch raw {
        case "paper":
            return .paper
        case "smartphone":
            return .smartphone
        case "tablet":
            return .tab
        case "ebook":
            return .ebook
        default:
            return .unknown
        }
    }
    
    init(raw: Int?) {
        if let int = raw {
            switch int {
            case 0:
                self = .paper
            case 1:
                self = .ebook
            case 2:
                self = .smartphone
            case 3:
                self = .tab
            default:
                self = .unknown
            }
        } else {
            self = .unknown
        }
    }
    
    func index() -> Int? {
        switch self {
        case .paper:
            return 0
        case .ebook:
            return 1
        case .smartphone:
            return 2
        case .tab:
            return 3
        case .unknown:
            return nil
        }
    }
}

public struct BookModel {
    public var id: String
    public var title: String
    public var author: String
    public var pagesCount: Int
    public var image: UIImage?
    public var lastUpdated: Date
    public var type: BookType
    public var isDeleted: Bool
    
    public init(id: String = "",
                title: String = "",
                author: String = "",
                pagesCount: Int = 0,
                image: UIImage? = nil,
                lastUpdated: Date = Date.distantPast,
                type: BookType = .unknown,
                isDeleted: Bool = false) {
        self.id = id
        self.title = title
        self.author = author
        self.pagesCount = pagesCount
        self.image = image
        self.lastUpdated = lastUpdated
        self.type = type
        self.isDeleted = isDeleted
    }
}
