//
//  Queries.swift
//  Reading Tracker
//
//  Created by Andrei Kirilenko on 06/01/2019.
//  Copyright © 2019 Andrei Kirilenko.
//  Copyright (c) 2017 Carmelo Gallo
//

import Foundation

struct BookQuery {
    var searchText: String
    var startIndex: Int
    var maxResults: Int
    enum Filter: String {
        case ebooks = "ebooks"
        case freeEbooks = "free-ebooks"
        case paidEbooks = "paid-ebooks"
    }
    var filter: Filter
    enum OrderBy: String {
        case relevance = "relevance"
        case newest = "newest"
    }
    var orderBy: OrderBy
}
