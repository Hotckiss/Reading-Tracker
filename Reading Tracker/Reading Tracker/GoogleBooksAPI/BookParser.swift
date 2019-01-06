//
//  BookParser.swift
//  Reading Tracker
//
//  Created by Andrei Kirilenko on 06/01/2019.
//  Copyright (c) 2017 Carmelo Gallo
//

import Foundation
import SwiftyJSON

struct BookModelAPI {
    var title: String?
    var authors: [String]?
    var subtitle: String?
    var textSnippet: String?
    var description: String?
    var averageRating: Double?
    var smallThumbnail: String?
    var thumbnail: String?
    
    init(title: String?,
         authors: [String]?,
         subtitle: String?,
         textSnippet: String?,
         description: String?,
         averageRating: Double?,
         smallThumbnail: String?,
         thumbnail: String?) {
        self.title = title
        self.authors = authors
        self.subtitle = subtitle
        self.textSnippet = textSnippet
        self.description = description
        self.averageRating = averageRating
        self.smallThumbnail = smallThumbnail
        self.thumbnail = thumbnail
    }
}

class BookParser {
    func parse(fromJSON json: JSON) -> [BookModelAPI] {
        var books = [BookModelAPI]()
        guard let items = json["items"].array else { return books }
        for item in items {
            books.append(BookModelAPI(title: item["volumeInfo"]["title"].string,
                                      authors: item["volumeInfo"]["authors"].arrayObject as? [String],
                                      subtitle: item["volumeInfo"]["subtitle"].string,
                                      textSnippet: item["searchInfo"]["textSnippet"].string,
                                      description: item["volumeInfo"]["description"].string,
                                      averageRating: item["volumeInfo"]["averageRating"].double,
                                      smallThumbnail: item["volumeInfo"]["imageLinks"]["smallThumbnail"].string,
                                      thumbnail: item["volumeInfo"]["imageLinks"]["thumbnail"].string))
        }
        return books
    }
}
