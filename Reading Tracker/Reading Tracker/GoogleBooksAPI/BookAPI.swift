//
//  BookAPI.swift
//  Reading Tracker
//
//  Created by Andrei Kirilenko on 06/01/2019.
//  Copyright © 2019 Andrei Kirilenko.
//  Copyright (c) 2017 Carmelo Gallo
//

import Foundation

protocol BookAPI {
    var baseURL: String { get set }
    init(baseURL: String)
    func get(bookQuery: BookQuery, completion: ((Result<[BookModelAPI]>) -> Void)?)
}

final class BookAPIImplementation: BookAPI {
    var baseURL: String
    
    init(baseURL: String) {
        self.baseURL = baseURL
    }
    
    func get(bookQuery: BookQuery, completion: ((Result<[BookModelAPI]>) -> Void)?) {
        let url =
            baseURL +
                "/volumes?" +
                //"filter=\(bookQuery.filter.rawValue)&" +
                "q=\(bookQuery.searchText)&" +
                "orderBy=\(bookQuery.orderBy.rawValue)&" +
                "startIndex=\(bookQuery.startIndex)&" +
        "maxResults=\(bookQuery.maxResults)"
        
        let encodedURLStrig = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let apiModel = APIModel(method: .get,
                                url: encodedURLStrig,
                                headers: nil,
                                params: nil,
                                paramsEncoding: .json)
        
        APIManager.instance.call(withAPIModel: apiModel) { result in
            switch result {
            case .success(let json):
                let books = BookParser().parse(fromJSON: json)
                completion?(Result.success(value: books))
            case .failure(let errorAPI):
                completion?(Result.failure(error: errorAPI))
            }
        }
    }
}
