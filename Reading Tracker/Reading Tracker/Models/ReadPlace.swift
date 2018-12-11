//
//  ReadPlace.swift
//  Reading Tracker
//
//  Created by Andrei Kirilenko on 11/12/2018.
//  Copyright © 2018 Andrei Kirilenko. All rights reserved.
//

import Foundation

public enum ReadPlace: String {
    case home = "home"
    case transport = "transport"
    case work = "work"
    case unknown = "unknown"
    
    init(ind: Int?) {
        if let ind = ind {
            switch ind {
            case 0:
                self = .home
            case 1:
                self = .transport
            case 2:
                self = .work
            default:
                self = .unknown
            }
        } else {
            self = .unknown
        }
    }
    
    init(str: String) {
        switch str {
        case "home":
            self = .home
        case "transport":
            self = .transport
        case "work":
            self = .work
        default:
            self = .unknown
        }
    }
    
    public static let all: [ReadPlace] = [.work, .transport, .home]
}
