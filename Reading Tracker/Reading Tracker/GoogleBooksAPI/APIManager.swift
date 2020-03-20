//
//  APIManager.swift
//  Reading Tracker
//
//  Created by Andrei Kirilenko on 06/01/2019.
//  Copyright (c) 2017 Carmelo Gallo
//

import Foundation
import Alamofire
import SwiftyJSON

enum APIError: Error {
    case noNetwork(error: Error?)
    case timeout(error: Error?)
    case networkConnectionLost(error: Error?)
    case general(error: Error?)
    case server_500(error: Error?)
}

struct APIModel {
    enum HTTPMethod: String {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
        case patch = "PATCH"
        case delete = "DELETE"
    }
    enum Encoding {
        case urlEncoded
        case json
    }
    var method: HTTPMethod
    var url: String
    var headers: [String: String]?
    var params: [String: Any]?
    var paramsEncoding: Encoding
}

struct APIConsts {
    static let baseURL = "https://www.googleapis.com/books/v1"
}

class APIManager {
    public static let instance = APIManager()
    var book: BookAPI
    
    private static let sessionManager: SessionManager = {
        return Alamofire.SessionManager()
    }()
    
    convenience init() {
        self.init(baseURL: APIConsts.baseURL)
    }
    
    init(baseURL: String) {
        book = BookAPIImplementation(baseURL: baseURL)
    }
    
    func call(withAPIModel apiModel: APIModel,
              completion: ((Result<JSON>) -> Void)?) {
        
        guard let method = HTTPMethod(rawValue: apiModel.method.rawValue) else {
            completion?(Result.failure(error: APIError.general(error: nil)))
            return
        }
        
        var encoding: ParameterEncoding
        if apiModel.paramsEncoding == .urlEncoded {
            encoding = URLEncoding.default
        } else {
            encoding = JSONEncoding.default
        }
        
        APIManager.sessionManager.request(apiModel.url,
                                          method: method,
                                          parameters: apiModel.params,
                                          encoding: encoding,
                                          headers: apiModel.headers)
            .validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])
            .responseData { response in
                switch response.result {
                case .success(let data):
                    completion?(Result.success(value: JSON(data)))
                case .failure(let error):
                    if let err = error as? URLError, case .notConnectedToInternet = err.code {
                        let errorAPI = APIError.noNetwork(error: error)
                        completion?(Result.failure(error: errorAPI))
                    } else if let err = error as? URLError, case .timedOut = err.code {
                        let errorAPI = APIError.timeout(error: error)
                        completion?(Result.failure(error: errorAPI))
                    } else if let err = error as? URLError, case .networkConnectionLost = err.code {
                        let errorAPI = APIError.networkConnectionLost(error: error)
                        completion?(Result.failure(error: errorAPI))
                    } else {
                        let errorAPI = APIError.general(error: error)
                        completion?(Result.failure(error: errorAPI))
                    }
                }
        }
    }
    
    func startNetworkReachabilityObserver() {
        let reachabilityManager = Alamofire.NetworkReachabilityManager(host: "www.google.com")
        reachabilityManager?.listener = { status in
            switch status {
            case .notReachable:
                print("---The network is not reachable")
            case .unknown :
                print("---It is unknown whether the network is reachable")
            case .reachable(.ethernetOrWiFi):
                print("---The network is reachable over the WiFi connection")
            case .reachable(.wwan):
                print("---The network is reachable over the WWAN connection")
            }
        }
        // start listening
        reachabilityManager?.startListening()
    }
}
